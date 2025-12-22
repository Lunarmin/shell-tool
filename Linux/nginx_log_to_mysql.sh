#!/bin/bash

LOG_FILE="/data/log/access.log"
DB_HOST="127.0.0.1"
DB_USER="log_push"
DB_PASS="log_push@123"
DB_NAME="log"
TABLE_NAME="nginx_log"

escape() {
    echo "${1//\'/\'\'}"
}

tail -F "$LOG_FILE" | while read -r line; do
    if [[ $line =~ ^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\ \-\ ([^\ ]*)\ ([0-9]+)\ \[([^\]]+)\]\ \"([^\"]+)\"\ ([0-9]+)\ ([0-9\.]+)\ ([0-9\-]+)\ \"([^\"]*)\"\ \"([^\"]+)\"\ \"([^\"]*)\"$ ]]; then
        # 提取字段
        remote_addr="${BASH_REMATCH[1]}"
        remote_user="${BASH_REMATCH[2]}"
        server_port="${BASH_REMATCH[3]}"
        time_local="${BASH_REMATCH[4]}"
        request="${BASH_REMATCH[5]}"
        status="${BASH_REMATCH[6]}"
        request_time="${BASH_REMATCH[7]}"
        body_bytes_sent="${BASH_REMATCH[8]}"
        http_referer="${BASH_REMATCH[9]}"
        http_user_agent="${BASH_REMATCH[10]}"
        http_x_forwarded_for="${BASH_REMATCH[11]}"

        # 拆解 request
        request_arr=($request)
        if [ ${#request_arr[@]} -eq 3 ]; then
            request_method="${request_arr[0]}"
            request_url="${request_arr[1]}"
            request_protocol="${request_arr[2]}"
        else
            request_method=""
            request_url=""
            request_protocol=""
        fi

        # 构造 SQL（注意转义单引号）
        SQL="INSERT INTO $TABLE_NAME (...) VALUES (...);"
        mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "$SQL"
    else
        echo "Failed to parse: $line" >> /var/log/nginx_log_parser.err
    fi
done

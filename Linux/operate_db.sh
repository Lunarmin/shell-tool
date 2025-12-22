#! /bin/bash

USERNAME=root 
PASSWORD=root
PORT=3306
IPADDRESS=172.0.0.1


database_names=`mysql -u${USERNAME} -p${PASSWORD} -h ${IPADDRESS} -P${PORT} -e "show databases like '%_test';" | awk 'NR>1{print $1}'`
for name in $database_names;
do
     #echo $name
   table_names=`mysql -u${USERNAME} -p${PASSWORD} -h ${IPADDRESS} -P${PORT} -e "select table_name from information_schema.tables where table_schema='$name'" | awk 'NR>1{print $1}'`
    for table_name in $table_names;
    do
	#echo $table_name
	table_count=`mysql -u${USERNAME} -p${PASSWORD} -h ${IPADDRESS} -P${PORT} -e "select count(1) as count from $name.$table_name;" | tail -1`
	if [ $table_count -eq 0 ];then
		echo "$name.$table_name=$table_count" >> /tmp/table_count_zero.log
	else	
		echo "$name.$table_name=$table_count" >> /tmp/table_count.log
	fi
    done
done









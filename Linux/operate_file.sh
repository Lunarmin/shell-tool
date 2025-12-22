#!/bin/bash

FILE_PATH=/home/.../*

for file in $(ls $FILE_PATH)
do
	# 选择.java结尾的文件处理
	# 提取文件后缀名： ${file##*.} 
	# ##是贪婪操作符，从左至右匹配，匹配到最右边的.号，移除包含.号的左边内容。
	if [ "${file##*.}"x = "java"x ];then
	 	#head -1 $FILE_PATH"/"$file # 读取第一行
		#sed -i "1s/com/com.learn/g" ·grep 6 -rl /home/.../**.java 其实一句话就能解决
		#进行文件处理
		sed -i "1s/com/com.learn/g" $FILE_PATH"/"$file
	fi
done

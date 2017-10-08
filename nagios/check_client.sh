#!/bin/bash

#计算ip这个文件有几个空行或者仅有空格的行
empty_line=`cat ip | egrep '(^\s*$|^.{1}$)' | wc -l`
#计算ip这个文件共有几行
all_line=`cat ip | wc -l`
#定义变量no来统计ip这个文件共有几行非空行，免除手动在for循环中填写需要检测的受控端数量
no=$[$all_line-$empty_line]


#引入no这个变量即得出受控端有几台，执行check_nrpe命令即可检测受控端是否在线，并将检测结果写入日志文件
for ((N=1;N<=$no;N++)); do
	ip=`sed -n "$N p" ip`
#> /dev/null 2>&1表示将前面的执行结果无论成功与否都不在屏幕显示
	/usr/local/nagios/libexec/check_nrpe -H $ip > /dev/null 2>&1
#得出上条命令的执行结果，执行成功就是0，失败则为其他数字
	result=`echo $?`
	
	if [ $result -eq 0 ]; then
		echo "$ip(nrpe) is ready" >> check_nrpe.log
	else
		echo "$ip(nrpe) is Installation failure..." >> check_nrpe.log
	fi
#换行
	echo "" >> check_nrpe.log
done

echo ""
echo '------------------- Nrpe client is check complete -------------------'
echo ""
echo 'Check the log "./check_nrpe.log", please!!!'
echo ""

exit
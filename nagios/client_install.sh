#!/bin/bash

empty_line=`cat ip | egrep '(^\s*$|^.{1}$)' | wc -l`
all_line=`cat ip | wc -l`
no=$[$all_line-$empty_line]

for ((N=1;N<=$no;N++)); do
	passwd=`sed -n "$N p" password`
	ip=`sed -n "$N p" ip`
#连接到每一台客户端服务器，下载nrpe客户端，下载地址如失效请重新定义	
	sshpass -p $passwd ssh root@$ip -o StrictHostKeyChecking=no "cd /tmp ; wget http://oe09162po.bkt.clouddn.com/nrpe_install.sh ; chmod +x nrpe_install.sh ; nohup ./nrpe_install.sh > nrpe_install.log 2>&1 &"
done

exit

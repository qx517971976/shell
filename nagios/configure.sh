#!/bin/bash

cfg=/etc/nagios/objects
nagios_base=/etc/nagios

#添加主机
empty_line=`cat hostname | egrep '(^\s*$|^.{1}$)' | wc -l`
all_line=`cat hostname | wc -l`
no=$[$all_line-$empty_line]

for ((C=1;C<=$no;C++)); do
        hostname=`sed -n "$C p" hostname`
        ip=`sed -n "$C p" ip`

echo "
define host{
	use             linux-server  
	host_name       $hostname
	alias           $hostname server
	address         $ip
}
        " >> $cfg/linux.cfg
done


#添加服务
#保存所有主机名到变量，已逗号为分隔符
empty_line=`cat hostname | egrep '(^\s*$|^.{1}$)' | wc -l`
all_line=`cat hostname | wc -l`
no=$[$all_line-$empty_line]

for ((C=1;C<=$no;C++)); do
	hostname=`sed -n "$C p" hostname`
	all_hostname=$all_hostname$hostname

	if [ $C -lt $no ]; then
		all_hostname=$all_hostname,
	fi
done

#服务参照此格式按需添加，一个服务一个模块
echo "
define service{
        use                             generic-service
        host_name                       $all_hostname
        service_description             Check sda1
        check_command                   check_nrpe!check_sda1
        }
" >> $cfg/linux.cfg

echo "
define service{
        use                             generic-service
        host_name                       $all_hostname
        service_description             Check sda2
        check_command                   check_nrpe!check_sda2
        }
" >> $cfg/linux.cfg

#将主机服务配置文件添加到nagios.cfg中
sed -i "/cfg_file=\/etc\/nagios\/objects\/templates.cfg/a\cfg_file=$cfg/linux.cfg" $nagios_base/nagios.cfg

#创建监控命令
echo '
define command {
        command_name check_nrpe
        command_line $USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$
}
' >> $cfg/commands.cfg

#启动nagios
service nagios restart

exit

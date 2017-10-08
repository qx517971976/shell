#!/bin/bash

NRPE_CFG=/usr/local/nagios/etc/nrpe.cfg
NRPE_CHECK=/usr/local/nagios/libexec

#下载nagios插件和nrpe安装包
wget http://oe09162po.bkt.clouddn.com/nagios-plugins-2.2.1.tar.gz
wget http://oe09162po.bkt.clouddn.com/nrpe-3.2.1.tar.gz

#添加nagios用户及安装依赖
useradd -s /sbin/nologin nagios
yum -y install gcc xinetd openssl-devel

#安装nagios插件
tar zxf nagios-plugins-2.2.1.tar.gz 
cd nagios-plugins-2.2.1
./configure --with-nagios-user=nagios --with-nagios-group=nagios
make all
make install

#安装nrpe
cd -
tar zxf nrpe-3.2.1.tar.gz
cd nrpe-3.2.1
./configure --with-nrpe-user=nagios \
     --with-nrpe-group=nagios \
     --with-nagios-user=nagios \
     --with-nagios-group=nagios \
     --enable-command-args \
     --enable-ssl
make all
make install-plugin
make install-daemon
make install-config

#设置监控端IP
sed -i -e 's|allowed_hosts=127.0.0.1,::1|allowed_hosts=192.168.80.121|' $NRPE_CFG

#添加命令
sed -i -e "s|command\[check_hda1\]=$NRPE_CHECK/check_disk -w 20% -c 10% -p \/dev\/hda1|command\[check_sda1\]=$NRPE_CHECK/check_disk -w 20% -c 10% -p \/dev\/sda1|" $NRPE_CFG

echo "command[check_sda2]=$NRPE_CHECK/check_disk -w 20% -c 10% -p /dev/sda2" >> $NRPE_CFG

echo "command[check_mysql]=$NRPE_CHECK/check_tcp -p 3306 -w 6 -c 10" >> $NRPE_CFG

#编写启动脚本
echo '
#!/bin/bash
# chkconfig: 2345 88 12
# description: NRPE DAEMON

NRPE=/usr/local/nagios/bin/nrpe
NRPECONF=/usr/local/nagios/etc/nrpe.cfg
NRPEPID=/usr/local/nagios/var

case "$1" in
	start)
		echo -n "Starting NRPE daemon..."
		$NRPE -c $NRPECONF -d
		echo " done."
		;;
	stop)
		echo -n "Stopping NRPE daemon..."
		pkill -u nagios nrpe
		echo " done."
		;;
	restart)
		$0 stop
		sleep 2
		$0 start
		;;
status)
if [ `ls -l $NRPEPID | wc -l` -eq 1 ]; then
echo "nrped is stopped"
else
echo "nrped is (pid `cat $NRPEPID/nrpe.pid`) running..."
fi
;;
	*)
echo "Usage: $0 start|stop|restart"
;;
	esac
exit 0
' > /etc/init.d/nrped

#将nrpe加入到开机自启并启动nrpe服务
chmod +x /etc/init.d/nrped
chkconfig --add nrped
chkconfig nrped on
service nrped restart

exit


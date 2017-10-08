#!/bin/bash

#下载nagios服务端、插件和nrpe安装包
wget http://oe09162po.bkt.clouddn.com/nagios-3.5.1.tar.gz
wget http://oe09162po.bkt.clouddn.com/nagios-plugins-2.2.1.tar.gz
wget http://oe09162po.bkt.clouddn.com/nrpe-3.2.1.tar.gz

#安装依赖
yum -y install httpd gcc glibc glibc-common gd gd-devel php mysql-devel php-mysql expect sshpass

#添加nagios运行所需要的用户和组
groupadd  nagcmd
useradd -G nagcmd nagios
usermod -a -G nagcmd apache
echo "abc123" | passwd --stdin nagios > /dev/null

#编译安装nagios
tar -zxvf nagios-3.5.1.tar.gz
cd nagios
./configure --sysconfdir=/etc/nagios --with-command-group=nagcmd --enable-event-broker 
make all
make install
make install-init
make install-commandmode
make install-config
make install-webconf
cd ..

#创建web页面登录用户
./nagios_web.sh /etc/nagios/htpasswd.users nagiosadmin abc123 > /dev/null

#启动httpd并添加到开机自启
service httpd restart
chkconfig httpd on

#编译安装nagios-plugins
tar -zxvf nagios-plugins-2.2.1.tar.gz 
cd nagios-plugins-2.2.1
./configure --with-nagios-user=nagios --with-nagios-group=nagios
make && make install
cd ..

#将nagios服务加入开机自启
chkconfig --add nagios
chkconfig nagios on

#安装NRPE
tar -zxvf nrpe-3.2.1.tar.gz
cd nrpe-3.2.1
#服务端安装时尽量使用和客户端一样的编译项
./configure --with-nrpe-user=nagios \
     --with-nrpe-group=nagios \
     --with-nagios-user=nagios \
     --with-nagios-group=nagios \
     --enable-command-args \
     --enable-ssl
make all
make install-plugin
cd ..

exit

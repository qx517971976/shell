#!/bin/bash

SYSCTL=/etc/sysctl.conf
RCLOCAL=/etc/rc.local
REDIS=/etc/init.d/redis
CONF=/etc/redis/6379.conf
IP=`/sbin/ifconfig|sed -n '/inet addr/s/^[^:]*:\([0-9.]\{7,15\}\) .*/\1/p' | head -n 1`

#和用户交互，接收用户的输入赋值给变量
read -p 'Please enter the password for redis: ' PASSWORD

echo -e
echo "---------- Now start installing redis ----------"

wget http://download.redis.io/releases/redis-3.0.7.tar.gz
tar -zxvf redis-3.0.7.tar.gz
cd redis-3.0.7
make PREFIX=/usr/local/redis install

mkdir /var/lib/redis_data
mkdir /etc/redis
cp redis.conf /etc/redis/6379.conf

#修改redis配置文件
sed -i -e 's?daemonize no?daemonize yes?' $CONF
sed -i -e 's?pidfile /var/run/redis.pid?pidfile /var/run/redis_6379.pid?' $CONF
sed -i -e "s?# bind 127.0.0.1?bind $IP?" $CONF
sed -i -e 's?logfile ""?logfile "/var/log/redis_6379.log"?' $CONF
sed -i -e 's?dir ./?dir /var/lib/redis_data?' $CONF
sed -i -e "s?# requirepass foobared?requirepass $PASSWORD?" $CONF

#创建启动脚本
cp utils/redis_init_script $REDIS
sed -i -e 's?EXEC=/usr/local/bin/redis-server?EXEC=/usr/local/redis/bin/redis-server?' $REDIS
sed -i -e 's?CLIEXEC=/usr/local/bin/redis-cli?CLIEXEC=/usr/local/redis/bin/redis-cli?' $REDIS
sed -i -e "s?\$CLIEXEC -p \$REDISPORT shutdown?\$CLIEXEC -h $IP -p \$REDISPORT -a $PASSWORD shutdown?" $REDIS
chmod +x $REDIS

#解决redis可能的报错
sysctl vm.overcommit_memory=1
echo 511 > /proc/sys/net/core/somaxconn
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo -e >> $SYSCTL
echo '# redis' >> $SYSCTL
echo 'vm.overcommit_memory=1' >> $SYSCTL
/sbin/sysctl -p
echo -e >> $RCLOCAL
echo '#redis' >> $RCLOCAL
echo 'echo 511 > /proc/sys/net/core/somaxconn' >> $RCLOCAL
echo 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' >> $RCLOCAL

service redis start

cd ..
rm -rf redis-3.0.7

echo -e
echo "---------- The redis installation is complete and started ----------"
echo "Check out the redis log,'more /var/log/redis_6379.log'"
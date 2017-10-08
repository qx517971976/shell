#本脚本仅限用于配置使用nrpe方式监控的linux服务器

#在当前目录下执行以下语句赋予所有脚本执行权限
chmod 755 *.sh

#在password、ip、hostname文件里分别填写客户端服务器的root密码、ip地址和主机名（用户标志nagios客户端名称，不一定要和服务器主机名一致），每行填写一个值，不要包含多余的字符，如空格、空行

#执行nagios_install.sh开始自动安装配置nagios服务端和客户端
./nagios_install.sh

#运行check_client.sh检查客户端是否全部安装完成，检查结果保存在check_nrpe.log中
#虽然在nagios_install.sh执行完毕后会提示直接运行check_client.sh，但实际上这还要取决于客户端的安装速度，建议等至少30分钟后再执行此脚本
./check_client.sh


#configure.sh脚本中可以自定义服务，如有超出预设值的监控命令请到nrpe_install.sh添加

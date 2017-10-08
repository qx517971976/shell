#!/usr/bin/expect

#创建nagios的web登录用户
set htpasswdpath [lindex $argv 0]
set username [lindex $argv 1]
set userpass [lindex $argv 2]

# spawn the htpasswd command process
spawn htpasswd -c $htpasswdpath $username

# Automate the 'New password' Procedure
expect "New password:"
send "$userpass\r"

expect "Re-type new password:"
send "$userpass\r"
expect eof

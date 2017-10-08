#!/bin/bash

echo ""
echo 'Start installing Nagios Core...'
nohup ./core_install.sh >> nagios_install.log
echo 'The Nagios Core install is complete!!!'
echo ""
echo ""
sleep 3

echo 'Start configuring Nagios...'
nohup ./configure.sh  >> nagios_install.log
echo 'The Nagios configuration is complete!!!'
echo ""
echo ""
sleep 3

echo 'Start installing Nrpe Client...'
nohup ./client_install.sh >> nagios_install.log
echo 'The Nrpe Client install is complete!!!'
echo ""
echo ""
sleep 3


echo 'Please run check_client.sh to complete the check...'
echo ""

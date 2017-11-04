#!/bin/bash

no=`cat no.txt | wc -l`

for ((C=1;C<=$no;C++)); do
    ip=`sed -n "$C p" no.txt`
    echo $ip
   # rrdtool update /root/test.rrd N:$ip
    sleep 1
done

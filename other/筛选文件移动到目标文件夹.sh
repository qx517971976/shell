#!/bin/bash

#源路径
SOURCE=/root/ceshi
#目标路径
TARGET=/root/ceshi1
#获取文件名
A=`ls /root/ceshi | sed -n "1p"`

for ((C=1;C<=3;C++)); do
    B=`ls /root/ceshi | sed -n "$((C+1))p"`
#保存获取到的所有文件名，文件名之间空格隔开
    A=$A" $B"
done

cd $SOURCE
#移动文件到目标路径
mv $A $TARGET

exit 3

#!/bin/bash
#打印值大于指定数字的行及其上一行内容

line=`wc -l apache.txt | awk '{print $1}'`

for ((C=2;C<=$line;C=C+4)); do
    value=`cut -d$'\n' -f$[C] apache.txt`
    value_before=`cut -d$'\n' -f$[$C-1] apache.txt`
    
    if [ $[value] -gt 80 ]; then
       echo $value_before
       echo $value
       echo ""
    fi
done

exit 3

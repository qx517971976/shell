#!/bin/bash


while [ 1 -eq 1 ]; do
    echo -e "\n" >> ceshi
    date >> ceshi
    w | head -1 | awk '{print $6" "$7$8" "$9" "$10}' >> ceshi
    sleep 3
done
    

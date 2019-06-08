#!/bin/bash
netstat -tulnap | grep $1 | grep -E 'TIME_WAIT|ESTABLISHED' | awk '{print $5}' | while read line; do
	perl /root/killcx.pl $line eth0;
done

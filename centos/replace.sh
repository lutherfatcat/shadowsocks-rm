#!/bin/bash
echo "Previous Table"
read pretbl
echo "Current Table"
read curtbl
echo "Start Port"
read startport
echo "End Port"
read endport
echo "ConnLimit"
read connlimit
sed -i -e s#$pretbl#$curtbl#g /root/shadowsocks-rm/db_transfer.py
prehost=${pretbl#*_}-${pretbl%_*}
curhost=${curtbl#*_}-${curtbl%_*}
hostname $curhost
sed -i -e s#$prehost#$curhost#g /etc/rc.d/rc.local
ports=$startport:$endport
sed -i -e "s#[0-9]\{5\}\:[0-9]\{5\}#$ports#" -e "s#connlimit-above [0-9]\{3\}#connlimit-above $connlimit#g" /root/firewall.rules
iptables-restore < /root/firewall.rules
pkill -9 -f server.py


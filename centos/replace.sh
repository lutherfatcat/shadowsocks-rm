#!/bin/bash
echo "Previous Table"
read pretbl
echo "Current Table"
read curtbl
sed -i -e s#$pretbl#$curtbl#g /root/shadowsocks-rm/db_transfer.py
pkill -9 -f server.py

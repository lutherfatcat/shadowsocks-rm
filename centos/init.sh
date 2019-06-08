#!/bin/bash
echo "Start Port"
read startport
echo "End Port"
read endport
echo "ConnLimit"
read connlimit
echo "SSR Table"
read ssrtable
echo "Hostname"
read hname
sed -i -e s#startport#$startport#g -e s#endport#$endport#g -e s#cnlt#$connlimit#g /root/firewall.rules
iptables-restore < /root/firewall.rules
mv /root/root /var/spool/cron/root
sed -i -e s#ss_table#$ssrtable#g /root/shadowsocks-rm/db_transfer.py
echo "sleep 60
chmod +x /root/firewall.rules
iptables-restore < /root/firewall.rules
pkill -9 -f server.py
hostname $hname" >> /etc/rc.d/rc.local
sed -i -e s#'exit 0'#''#g /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local
systemctl enable supervisord
echo "files = supervisord.d/*.conf" >> /etc/supervisord.conf
echo "[program:shadowsocks]
command = python2.7 /root/shadowsocks-rm/server.py
user = root
autostart = true
autorestart = true
stderr_logfile = /var/log/shadowsocks.log
stdout_logfile = /var/log/shadowsocks_error.log" >> /etc/supervisord.d/shadowsocks.conf
echo "* soft nofile 51200
* hard nofile 51200" >> /etc/security/limits.conf
echo "# max open files
fs.file-max = 51200
# max read buffer
net.core.rmem_max = 67108864
# max write buffer
net.core.wmem_max = 67108864
# default read buffer
net.core.rmem_default = 65536
# default write buffer
net.core.wmem_default = 65536
# max processor input queue
net.core.netdev_max_backlog = 4096
# max backlog
net.core.somaxconn = 4096

# resist SYN flood attacks
net.ipv4.tcp_syncookies = 1
# reuse timewait sockets when safe
net.ipv4.tcp_tw_reuse = 1
# turn off fast timewait sockets recycling
net.ipv4.tcp_tw_recycle = 0
# short FIN timeout
net.ipv4.tcp_fin_timeout = 30
# short keepalive time
net.ipv4.tcp_keepalive_time = 300
# outbound port range
net.ipv4.ip_local_port_range = 10000 65000
# max SYN backlog
net.ipv4.tcp_max_syn_backlog = 4096
# max timewait sockets held by system simultaneously
net.ipv4.tcp_max_tw_buckets = 5000
# turn on TCP Fast Open on both client and server side
net.ipv4.tcp_fastopen = 3
# TCP receive buffer
net.ipv4.tcp_rmem = 4096 87380 67108864
# TCP write buffer
net.ipv4.tcp_wmem = 4096 65536 67108864
# turn on path MTU discovery
net.ipv4.tcp_mtu_probing = 1" >> /etc/sysctl.conf

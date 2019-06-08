<?php

function writeLogs($type, $flag, $cw_count, $wt_count, $es_count) {
	$file = '/root/logs/' . $GLOBALS['thismonth'] . '/' . ($type == 'BLACK' ? 'blacklist_' : 'shadowsocks_') . $GLOBALS['today'] . '.txt' ;
	$logs = gethostname() . '_' . $flag . '_' . $cw_count . '_' . $wt_count . '_' . $es_count . '_' . $GLOBALS['time'] . '_' . $GLOBALS['ip'] . '_' . $GLOBALS['port'] . '_' . $GLOBALS['lk_count'] . "\n";
	file_put_contents($file, $logs, FILE_APPEND);
}

function flushFirewall() {
	exec("iptables -P INPUT ACCEPT");
	exec("iptables -P FORWARD ACCEPT");
	exec("iptables -P OUTPUT ACCEPT");
	exec("iptables -F");
	exec("iptables -X");
	exec("iptables-restore < /root/firewall.rules");
}

function restartShadowsocks() {
	exec("pkill -9 -f server.py");
}

function killAbuser() {
	exec("tcpkill -i eth0 port $GLOBALS[port] >/dev/null 2>/dev/null &");
	exec("tcpkill -i eth0 host $GLOBALS[ip] >/dev/null 2>/dev/null &");
}

date_default_timezone_set('Asia/Shanghai');

$thismonth = date('Y-m');
$today = date('Y-m-d');
$time = date("H:i");

$folder = '/root/logs/' . $GLOBALS['thismonth'];
if(!is_dir($folder)) {
    mkdir($folder, 0777, true);
}

exec("netstat -tun | grep -E '[1-6][0-9]{4}' | grep -vE '1.1.1.1|4.2.2.1|8.8.8.8|:22|:80|:3306|udp6|LISTEN' | awk '{print $4 \":\" $5}' | cut -d':' -f2,3 | sed 's/:/ /g' | sort | uniq -c | sort -rn", $string);
exec("netstat -tun | grep -c WAIT | awk '{print $1}'", $wt_count);
exec("netstat -tun | grep -c CLOSE_WAIT | awk '{print $1}'", $cw_count);
exec("netstat -tun | grep -c ESTABLISHED | awk '{print $1}'", $es_count);

list($lk_count, $port, $ip) = isset($string[0]) ? explode(" ", ltrim($string[0])) : array(0, 'PT', 'IP');

if($cw_count[0] > 50) {
	flushFirewall();
	restartShadowsocks();
	if($lk_count > 150) {
		if($port < 35000 || $port >= 40000 && $port < 65000) {
			killAbuser();
			writeLogs('LOG', 'CR', $cw_count[0], $wt_count[0], $es_count[0]);
			writeLogs('BLACK', 'CR', $cw_count[0], $wt_count[0], $es_count[0]);
		}
	} else {
		writeLogs('LOG', 'CW', $cw_count[0], $wt_count[0], $es_count[0]);
	}
} elseif(($wt_count[0] - 20) > $es_count[0] && $wt_count[0] > 50) {
	if($lk_count > 150) {
		if($port < 35000 || $port >= 40000 && $port < 65000) {
			killAbuser();
			exec("bash /root/killcx.sh $port >/dev/null 2>/dev/null &");
			writeLogs('LOG', 'ER', $cw_count[0], $wt_count[0], $es_count[0]);
			writeLogs('BLACK', 'ER', $cw_count[0], $wt_count[0], $es_count[0]);
		}
	} else {
		writeLogs('LOG', 'JM', $cw_count[0], $wt_count[0], $es_count[0]);
	}
} else {
	exec("pkill -9 -f tcpkill");
	writeLogs('LOG', 'OK', $cw_count[0], $wt_count[0], $es_count[0]);
}

?>

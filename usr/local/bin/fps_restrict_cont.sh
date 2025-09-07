#!/bin/sh

USE_RESTRICT=`uci get fps.config.restrict`
IP_ADDR=`uci get lte-gw.local_param.local_ip_addr`

if [ -f /usr/bin/finger_sensor ]; then
	if [ $USE_RESTRICT == "enable" ]
	then
		if [ -f /tmp/authorized ]; then
			iptables -t nat -D PREROUTING -p tcp -i br0 --dport 80 -j DNAT --to-destination $IP_ADDR:80 > /dev/null 2>&1
			iptables -t nat -D PREROUTING -p tcp -i br0 --dport 443 -j DNAT --to-destination $IP_ADDR:443 > /dev/null 2>&1
		else
			iptables -t nat -D PREROUTING -p tcp -i br0 --dport 80 -j DNAT --to-destination $IP_ADDR:80 > /dev/null 2>&1
			iptables -t nat -D PREROUTING -p tcp -i br0 --dport 443 -j DNAT --to-destination $IP_ADDR:443 > /dev/null 2>&1

			iptables -t nat -I PREROUTING -p tcp -i br0 --dport 80 -j DNAT --to-destination $IP_ADDR:80 > /dev/null 2>&1
			iptables -t nat -I PREROUTING -p tcp -i br0 --dport 443 -j DNAT --to-destination $IP_ADDR:443 > /dev/null 2>&1
		fi
	else
			iptables -t nat -D PREROUTING -p tcp -i br0 --dport 80 -j DNAT --to-destination $IP_ADDR:80 > /dev/null 2>&1
			iptables -t nat -D PREROUTING -p tcp -i br0 --dport 443 -j DNAT --to-destination $IP_ADDR:443 > /dev/null 2>&1

#			touch /tmp/authorized > /dev/null 2>&1
	fi
fi

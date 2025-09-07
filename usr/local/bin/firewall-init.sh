#!/bin/sh

SET_FIRE=`uci get firewall.config.firewall`
SET_ICMP=`uci get firewall.config.ping`
SET_HTTP=`uci get firewall.config.http`
SET_HTTP_PORT=`uci get firewall.config.http_port`
SET_RE_ICMP=`uci get firewall.config.icmp`
INTERNET_INTERACE_FILE='/tmp/internet_if.txt'
IPTABLES_CONFIG_FILE="/tmp/iptables"
SEC_PORT="8080"
TR69_PORT="7547"


if [ ! -e $INTERNET_INTERACE_FILE ]
then
    exit
fi

LTE_INTERFACE=`cat $INTERNET_INTERACE_FILE`

redirect_setting() {
    if [ $SET_RE_ICMP == "disable" ] 
    then
        echo "0" > /proc/sys/net/ipv4/conf/all/accept_redirects > /dev/null 2>&1
    else
        echo "1" > /proc/sys/net/ipv4/conf/all/accept_redirects > /dev/null 2>&1
    fi
}

firewall_nat() {
	if [ $SET_HTTP != "disable" ]; then
		echo "-I PREROUTING -i $LTE_INTERFACE -p tcp --dport $SET_HTTP_PORT -j REDIRECT --to $SEC_PORT" >> $IPTABLES_CONFIG_FILE
	fi
}

firewall_filter() {

	echo "-I INPUT -i $LTE_INTERFACE -p tcp --dport 80 -j DROP" >> $IPTABLES_CONFIG_FILE
	echo "-I INPUT -i $LTE_INTERFACE -p tcp --dport 443 -j DROP" >> $IPTABLES_CONFIG_FILE
#	echo "-I INPUT -i br0 -p tcp --dport 53 -j DROP" >> $IPTABLES_CONFIG_FILE

	if [ $SET_HTTP == "disable" ]; then
		echo "-I INPUT -i $LTE_INTERFACE -p tcp --dport $SET_HTTP_PORT -j DROP" >> $IPTABLES_CONFIG_FILE
	else
		echo "-I INPUT -i $LTE_INTERFACE -p tcp --dport $SET_HTTP_PORT -j ACCEPT" >> $IPTABLES_CONFIG_FILE
	fi

	if [ $SET_ICMP == "disable" ]; then
		echo "-I INPUT -i $LTE_INTERFACE -p ICMP -j DROP" >> $IPTABLES_CONFIG_FILE
		echo "-I INPUT -i $LTE_INTERFACE -p icmp --icmp-type 0 -m state --state ESTABLISHED,RELATED -j ACCEPT" >> $IPTABLES_CONFIG_FILE
	else
		echo "-I INPUT -i $LTE_INTERFACE -p ICMP -j ACCEPT" >> $IPTABLES_CONFIG_FILE
	fi

	if [ $SET_FIRE == "enable" ]; then
		echo "-I INPUT -i $LTE_INTERFACE -j DROP" >> $IPTABLES_CONFIG_FILE
		echo "-I INPUT -i $LTE_INTERFACE -m state --state ESTABLISHED,RELATED -j ACCEPT" >> $IPTABLES_CONFIG_FILE
		echo "-I INPUT -i $LTE_INTERFACE -p tcp --dport $TR69_PORT -j ACCEPT" >> $IPTABLES_CONFIG_FILE
	fi
	redirect_setting
}

case "$1" in
    nat)
        firewall_nat
        ;;
    filter)
        firewall_filter
        ;;
esac


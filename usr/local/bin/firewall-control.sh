#!/bin/sh

SET_FIRE=`uci get firewall.config.firewall`
SET_ICMP=`uci get firewall.config.ping`
SET_HTTP=`uci get firewall.config.http`
SET_HTTP_PORT=`uci get firewall.config.http_port`
SET_RE_ICMP=`uci get firewall.config.icmp`

firewall_setting() {
    if [ $SET_FIRE == "enable" ] 
    then
		iptables -I INPUT -i lte0 -m state --state ESTABLISHED,RELATED -j ACCEPT > /dev/null 2>&1
		iptables -I INPUT -i lte0 -j DROP > /dev/null 2>&1
    else
		iptables -D INPUT -i lte0 -m state --state ESTABLISHED,RELATED -j ACCEPT > /dev/null 2>&1
		iptables -D INPUT -i lte0 -j DROP > /dev/null 2>&1
    fi
}
redirect_setting() {
    if [ $SET_RE_ICMP == "disable" ] 
    then
        echo "0" > /proc/sys/net/ipv4/conf/all/accept_redirects > /dev/null 2>&1
    else
        echo "1" > /proc/sys/net/ipv4/conf/all/accept_redirects > /dev/null 2>&1
    fi
}
http_setting() {
    if [ $SET_HTTP == "disable" ] 
    then
		iptables -D INPUT -i lte0 -p tcp --dport 80 -j ACCEPT >> /dev/null 2>&1
		iptables -t nat -D PREROUTING -i lte0 -p tcp --dport $SET_HTTP_PORT -j REDIRECT --to 80 > /dev/null 2>&1
		iptables -t nat -D PREROUTING -i lte0 -p tcp --dport 80 -j REDIRECT --to $SET_HTTP_PORT > /dev/null 2>&1

		iptables -I INPUT -i lte0 -p tcp --dport 80 -j DROP > /dev/null 2>&1
    else
        iptables -D INPUT -i lte0 -p tcp --dport 80 -j DROP > /dev/null 2>&1

		iptables -I INPUT -i lte0 -p tcp --dport 80 -j ACCEPT >> /dev/null 2>&1
		iptables -t nat -I PREROUTING -i lte0 -p tcp --dport $SET_HTTP_PORT -j REDIRECT --to 80 > /dev/null 2>&1
		iptables -t nat -I PREROUTING -i lte0 -p tcp --dport 80 -j REDIRECT --to $SET_HTTP_PORT > /dev/null 2>&1
    fi
}
icmp_setting() {
    if [ $SET_ICMP == "disable" ] 
    then
		iptables -D INPUT -i lte0 -p ICMP -j ACCEPT > /dev/null 2>&1
		iptables -I INPUT -i lte0 -p ICMP -j DROP > /dev/null 2>&1
		iptables -I INPUT -i lte0 -p icmp --icmp-type 0 -m state --state ESTABLISHED,RELATED -j ACCEPT > /dev/null 2>&1
    else
		iptables -D INPUT -i lte0 -p ICMP -j DROP > /dev/null 2>&1
		iptables -D INPUT -i lte0 -p icmp --icmp-type 0 -m state --state ESTABLISHED,RELATED -j ACCEPT > /dev/null 2>&1
		iptables -I INPUT -i lte0 -p ICMP -j ACCEPT > /dev/null 2>&1
    fi
}
firewall_init() {
    if [ $SET_HTTP == "disable" ] 
    then
		iptables -I INPUT -i lte0 -p tcp --dport 80 -j DROP  > /dev/null 2>&1
    else
		iptables -I INPUT -i lte0 -p tcp --dport 80 -j ACCEPT  > /dev/null 2>&1
		iptables -t nat -I PREROUTING -i lte0 -p tcp --dport $SET_HTTP_PORT -j REDIRECT --to 80  > /dev/null 2>&1
		iptables -t nat -I PREROUTING -i lte0 -p tcp --dport 80 -j REDIRECT --to $SET_HTTP_PORT  > /dev/null 2>&1
    fi

    if [ $SET_ICMP == "disable" ] 
    then
		iptables -I INPUT -i lte0 -p ICMP -j DROP > /dev/null 2>&1
		iptables -I INPUT -i lte0 -p icmp --icmp-type 0 -m state --state ESTABLISHED,RELATED -j ACCEPT > /dev/null 2>&1
    else
		iptables -I INPUT -i lte0 -p ICMP -j ACCEPT > /dev/null 2>&1
    fi

	if [ $SET_FIRE == "enable" ] 
    then
		iptables -I INPUT -i lte0 -m state --state ESTABLISHED,RELATED -j ACCEPT > /dev/null 2>&1
		iptables -I INPUT -i lte0 -j DROP > /dev/null 2>&1
    fi
    redirect_setting
}

iptables_clear() {
    iptables -F
}

case "$1" in
    init)
        firewall_init
        fps_restrict_cont.sh > /dev/null 2>&1
        ;;
    clear)
        iptables_clear
        ;;
    firewall)
        firewall_setting
        fps_restrict_cont.sh > /dev/null 2>&1
        ;;
    icmp)
        icmp_setting
        fps_restrict_cont.sh > /dev/null 2>&1
        ;;
   http)
        http_setting
        fps_restrict_cont.sh > /dev/null 2>&1
        ;;
   redirect)
        redirect_setting
        fps_restrict_cont.sh > /dev/null 2>&1
        ;;
   port)
		iptables -t nat -D PREROUTING -i lte0 -p tcp --dport $2 -j REDIRECT --to 80  > /dev/null 2>&1
		iptables -t nat -D PREROUTING -i lte0 -p tcp --dport 80 -j REDIRECT --to $2  > /dev/null 2>&1
		iptables -t nat -I PREROUTING -i lte0 -p tcp --dport $SET_HTTP_PORT -j REDIRECT --to 80  > /dev/null 2>&1
		iptables -t nat -I PREROUTING -i lte0 -p tcp --dport 80 -j REDIRECT --to $SET_HTTP_PORT  > /dev/null 2>&1

        fps_restrict_cont.sh > /dev/null 2>&1
		;;
esac

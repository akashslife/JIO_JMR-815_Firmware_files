#!/bin/sh

. /usr/local/bin/lte-gw-global-env.sh
LOCAL_TOPOLOGY=`uci get lte-gw.local_param.local_topoloy`

if [ $LAN_IF = "eth0" ]; then
echo "ethtool:"
echo "========"
ethtool eth0
fi

echo "IPv4 Route:"
echo "========="
ip route

echo "IPv6 Route:"
echo "========="
ip -6 route

echo "arp:"
echo "===="
arp -a

echo "iptables:"
echo "========="
echo "mangle table:"
echo "============="
iptables -t mangle -L -v -n
echo "filter table:"
echo "============="
iptables -t filter -L -v -n
echo "nat table:"
echo "=========="
iptables -t nat -L -v -n

if [ $LOCAL_TOPOLOGY == "bridge" ]; then
    echo "brctl show:"
    echo "==========="
    brctl show br0
    echo "brctl showmacs:"
    echo "==============="
    brctl showmacs br0

    echo "ebtables:"
    echo "========="
    echo "broute table:"
    echo "============="
    ebtables -t broute -L --Lc
    echo "nat table:"
    echo "=========="
    ebtables -t nat -L --Lc
    echo "filter table:"
    echo "============="
    ebtables -t filter -L --Lc
fi



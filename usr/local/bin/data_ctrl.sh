#!/bin/sh

ARGC=$#
BLOCK=$1

block_add()
{
    #block IPV4 packets
    iptables -t filter -I FORWARD -j DROP
    # alow DHCP
    iptables -t filter -I FORWARD -p udp --dport 67:68 -j ACCEPT

    #block IPV6 packets
    ip6tables -t filter -I FORWARD -j DROP
    # alow IPV6 RS RA
    ip6tables -t filter -I FORWARD -p icmpv6 --icmpv6-type 133
    ip6tables -t filter -I FORWARD -p icmpv6 --icmpv6-type 134
    ip6tables -t filter -I FORWARD -p icmpv6 --icmpv6-type 135
    ip6tables -t filter -I FORWARD -p icmpv6 --icmpv6-type 136
}

block_remove()
{
    #block IPV4 packets
    iptables -t filter -D FORWARD -j DROP
    # alow DHCP
    iptables -t filter -D FORWARD -p udp --dport 67:68 -j ACCEPT

    #block IPV6 packets
    ip6tables -t filter -D FORWARD -j DROP
    # alow IPV6 RS RA
    ip6tables -t filter -D FORWARD -p icmpv6 --icmpv6-type 133
    ip6tables -t filter -D FORWARD -p icmpv6 --icmpv6-type 134
    ip6tables -t filter -D FORWARD -p icmpv6 --icmpv6-type 135
    ip6tables -t filter -D FORWARD -p icmpv6 --icmpv6-type 136
}

if [ $ARGC -eq 1 ]; then
    if [ $BLOCK == "1" ]; then
        block_add
    else
        block_remove
    fi
else
    echo "Error: option not supported!"
    exit 1
fi



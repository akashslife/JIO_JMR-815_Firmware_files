#!/bin/sh
IPT6="/usr/sbin/ip6tables"
PUBIF="lte0.1"
LANIF="br0"
TR69_PORT="7547"
DHCPV6_PORT="546"
LOCAL_IP=`ifconfig br0 | grep "inet6 addr:" | grep "Scope:Link" | awk '{ print $3 }'`

$IPT6 -F
$IPT6 -X


# unlimited access to loopback
#$IPT6 -A INPUT -i lo -j ACCEPT
#$IPT6 -A OUTPUT -o lo -j ACCEPT

# unlimited access to internal network
#$IPT6 -A INPUT -s fe80::211:22ff:fe33:4455/64 -d  fe80::211:22ff:fe33:4455/64 -j ACCEPT
#$IPT6 -A OUTPUT -s fe80::211:22ff:fe33:4455/64 -d  fe80::211:22ff:fe33:4455/64 -j ACCEPT
# Remove
#$IPT6 -A INPUT -s $LOCAL_IP -d $LOCAL_IP -j ACCEPT
#$IPT6 -A OUTPUT -s $LOCAL_IP -d $LOCAL_IP -j ACCEPT


# DROP all incomming traffic
$IPT6 -P INPUT DROP
$IPT6 -P OUTPUT DROP
#$IPT6 -P FORWARD DROP


# unlimited access from usb0(lan side)
$IPT6 -A INPUT -i br0 -j ACCEPT
$IPT6 -A OUTPUT -o br0 -j ACCEPT


# Allow full outgoing connection but no incomming stuff
$IPT6 -A INPUT -i $PUBIF -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT6 -A OUTPUT -o $PUBIF -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT


# allow incoming ICMP ping pong stuff
$IPT6 -A INPUT -i $PUBIF -p ipv6-icmp -j ACCEPT
$IPT6 -A OUTPUT -o $PUBIF -p ipv6-icmp -j ACCEPT


# open IPv6  port (7547) for TR-069 
$IPT6 -A INPUT -i $PUBIF -p tcp --destination-port $TR69_PORT -j ACCEPT

# open IPv6  port (546) for DHCPv6 
$IPT6 -A INPUT -i $PUBIF -p udp --destination-port $DHCPV6_PORT -j ACCEPT

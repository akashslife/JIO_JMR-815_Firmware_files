#! /bin/sh
# $Id: iptables_init.sh,v 1.10 2017/04/21 11:16:09 nanard Exp $
IPTABLES="`which iptables`" || exit 1
IPTABLES="$IPTABLES -w"
IP="`which ip`" || exit 1

#change this parameters :
#EXTIF=eth0
#EXTIF="`LC_ALL=C $IP -4 route | grep 'default' | sed -e 's/.*dev[[:space:]]*//' -e 's/[[:space:]].*//'`" || exit 1
#EXTIP="`LC_ALL=C $IP -4 addr show $EXTIF | awk '/inet/ { print $2 }' | cut -d "/" -f 1`"

#Check if chain exist 
iptables -t nat -n --list MINIUPNPD
if [ $? == '0' ]
then
    echo "UPnP Init iptables rules, chain already exists" > /dev/kmsg
    exit 0
fi

echo "UPnP Init iptables rules" > /dev/kmsg


INTERNET_INTERACE_FILE='/tmp/internet_if.txt'
#Check the the file exist.
if [ ! -e $INTERNET_INTERACE_FILE ]
then
    EXTIF=`uci get lte-gw.nat.upnp_wan_if`
else
    #The internet LTE interface lte0 / lte0.1 etc...
    EXTIF=`cat $INTERNET_INTERACE_FILE` 
fi


#adding the MINIUPNPD chain for nat
$IPTABLES -t nat -N MINIUPNPD
#adding the rule to MINIUPNPD
#$IPTABLES -t nat -A PREROUTING -d $EXTIP -i $EXTIF -j MINIUPNPD
$IPTABLES -t nat -I PREROUTING -i $EXTIF -j MINIUPNPD

#adding the MINIUPNPD chain for mangle
$IPTABLES -t mangle -N MINIUPNPD
$IPTABLES -t mangle -I PREROUTING -i $EXTIF -j MINIUPNPD

#adding the MINIUPNPD chain for filter
$IPTABLES -t filter -N MINIUPNPD
#adding the rule to MINIUPNPD
$IPTABLES -t filter -I FORWARD -i $EXTIF ! -o $EXTIF -j MINIUPNPD

#adding the MINIUPNPD chain for nat
$IPTABLES -t nat -N MINIUPNPD-POSTROUTING
$IPTABLES -t nat -I POSTROUTING -o $EXTIF -j MINIUPNPD-POSTROUTING

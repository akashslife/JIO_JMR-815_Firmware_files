#!/bin/sh

NAT_DMZ_ENABLE=`uci get lte-gw.nat.dmz_enable`
NAT_DMZ_IP=`uci get lte-gw.nat.dmz_host_ip`

OPERATION=$1
MAC=$2
IP=$3

#The first allocated DHCP Address is the DMZ host.
if [ $OPERATION == "add" ]
then
    if [ $NAT_DMZ_IP == "0.0.0.0" ]
    then 
        NAT_DMZ_IP=`uci set lte-gw.nat.dmz_host_ip=$IP >/dev/null 2>&1`
        uci commit >/dev/null 2>&1
    fi
fi


if [ $NAT_DMZ_ENABLE == "enable" ] 
then
    nat-conf.sh
fi


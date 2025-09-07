#!/bin/sh
HOSTNAME=$1
NEWNAME=$2
LOCAL_IP=`uci get lte-gw.local_param.local_ip_addr`

echo "$NEWNAME" > /etc/hostname
hostname -F /etc/hostname
sed -i "/$HOSTNAME/d" /etc/hosts
echo "$LOCAL_IP $NEWNAME" >> /etc/hosts

sed -i "s/$HOSTNAME/$NEWNAME/g" /etc/lighttpd.conf


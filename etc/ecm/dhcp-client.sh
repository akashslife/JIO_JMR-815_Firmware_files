#!/bin/sh

[ -z "$1" ] && echo "Error: should be called from udhcpc" >> /dev/kmsg && exit 1

BASE_FILE_PATH=/etc/
LEASE_FILE_PATH=/tmp/
LEASE_FILE_NAME=dhcp_differed_lease

echo "$0 called by DHCP client with arg: $1" > /dev/kmsg

cp $BASE_FILE_PATH$LEASE_FILE_NAME $LEASE_FILE_PATH$LEASE_FILE_NAME
if [ $? -ne "0" ]; then
	echo "$0: Failed to copy lease file" >> /dev/kmsg
fi 

case "$1" in
	deconfig)
	;;
	leasefail|nak)
		echo "$0: DHCP Lease failed." >> /dev/kmsg
		
	;;
	renew|bound)
		uci set -c /tmp/ $LEASE_FILE_NAME.leasedata.ip="$ip"	
		uci set -c /tmp/ $LEASE_FILE_NAME.leasedata.subnet="$subnet"
		uci set -c /tmp/ $LEASE_FILE_NAME.leasedata.router="$router"
		uci set -c /tmp/ $LEASE_FILE_NAME.leasedata.broadcast="$broadcast"
		uci set -c /tmp/ $LEASE_FILE_NAME.leasedata.domain="$domain"
		uci set -c /tmp/ $LEASE_FILE_NAME.leasedata.dns="$dns"

		uci commit -c /tmp/ $LEASE_FILE_NAME
		;;
esac

exit 0

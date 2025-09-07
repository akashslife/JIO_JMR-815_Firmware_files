#!/bin/sh

. /usr/local/bin/lte-gw-global-env.sh

LOCAL_IP=`uci get lte-gw.local_param.local_ip_addr`
RANGE_FROM=`uci get lte-gw.dhcp_srv.range_from_ip`
RANGE_TO=`uci get lte-gw.dhcp_srv.range_to_ip`
DMZ_HOST=`uci get lte-gw.nat.dmz_host_ip`

TARGET_DIR="/etc/config"
PARAM1=$1

IFS="."
set -- $LOCAL_IP
oc1=$1
oc2=$2
#oc3=0 //altair original
oc3=$3
IP_HIGE="$oc1.$oc2.$oc3"

#--- range_from_ip ---
set -- $RANGE_FROM
oc4=$4
uci set lte-gw.dhcp_srv.range_from_ip="$IP_HIGE.$oc4" > /dev/null 2>&1
uci commit lte-gw.dhcp_srv.range_from_ip > /dev/null 2>&1

#--- range_to_ip ---
set -- $RANGE_TO
oc4=$4
uci set lte-gw.dhcp_srv.range_to_ip="$IP_HIGE.$oc4" > /dev/null 2>&1
uci commit lte-gw.dhcp_srv.range_to_ip > /dev/null 2>&1

#dmz_host_ip
if [ "$DMZ_HOST" != "0.0.0.0" ]
then
    set -- $DMZ_HOST
    oc4=$4
    uci set lte-gw.nat.dmz_host_ip="$IP_HIGE.$oc4" > /dev/null 2>&1
    uci commit lte-gw.nat.dmz_host_ip > /dev/null 2>&1
fi

uci set lte-gw.dhcp_srv.host_reservation_num="0" > /dev/null 2>&1
uci commit lte-gw.dhcp_srv.host_reservation_num > /dev/null 2>&1
echo "" > $TARGET_DIR/lte-gw-dhcp-hosts

uci set lte-gw.nat.port_fwd_num="0" > /dev/null 2>&1
uci commit lte-gw.nat.port_fwd_num > /dev/null 2>&1
echo "" > $TARGET_DIR/lte-gw-port-fwd

`/usr/local/bin/dhcp-ctrl.sh stop > /dev/null 2>&1`
#Configure DHCP params for router / bridge
sh /usr/local/bin/dhcp-conf.sh
# the web GUI will reset on its own
if  [ "$PARAM1" != "no-reset" ]
then
	reboot
fi

#NTmore added
fw_setenv reboot 1
sync
echo "Config Reset" >/etc/config/reason_start
reboot


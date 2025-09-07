#!/bin/sh
#get a list of connected stations 

local rtl_wlan_modules_dir="/lib/modules/`uname -r`/extra/wlan_rtl"
if [ -e /proc/device-tree/wlan_type ]; then
        WLAN_TYPE=$(cat /proc/device-tree/wlan_type);
else
        WLAN_TYPE="ATH"
fi

let quiet=0
if [ "$1" == "-q" ]; then
        let quiet=1
fi
if [ $quiet -eq 0 ]; then
        echo "connected stations for wlan0"
fi
if [ $WLAN_TYPE == "ATH" ] ; then
    wmiconfig -i wlan0 --getsta 2>/dev/null |  sed -n /STATION/p | awk '{print $4}' | sed s/MAC://g
else
    alt_get_conn_stats.sh /proc/wlan0
fi

if [ $quiet -eq 0 ]; then
        echo "connected stations for wlan1"
fi

if [ $WLAN_TYPE == "ATH" ] ; then
    wmiconfig -i wlan1 --getsta 2>/dev/null |  sed -n /STATION/p | awk '{print $4}' | sed s/MAC://g
else
    alt_get_conn_stats.sh /proc/wlan0-va0
fi







#!/bin/sh


#if [ -e /proc/device-tree/wlan_type ]; then
#        WLAN_TYPE=$(cat /proc/device-tree/wlan_type);
#else
#        WLAN_TYPE="ATH"
#fi

#if [ $WLAN_TYPE == "ATH" ]; then
#    echo $1 > /sys/devices/platform/alt3100_pm_driver/no_host
#else
	echo $1 > /sys/devices/soc.0/b0220200.pm/no_host
#fi


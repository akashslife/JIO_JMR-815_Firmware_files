#!/bin/sh
kernel_ver=$(uname -r)

if [ "$FIRMWARE" != "" -a "$ACTION" == "add" ] ; then
    if [ -f /lib/modules/${kernel_ver}/extra/wlan_p_drv/${FIRMWARE} ]; then
        echo 1 > /sys/${DEVPATH}/loading
        cat /lib/modules/${kernel_ver}/extra/wlan_p_drv/${FIRMWARE} > /sys/${DEVPATH}/data
#        usleep 500000
        echo 0 > /sys/${DEVPATH}/loading
    else
        echo -1 > /sys/${DEVPATH}/loading
    fi
fi 

#!/bin/sh
#
#
#Export the relevent interfaces name
. /usr/local/bin/lte-gw-global-env.sh


#local rtl_wlan_modules_dir="/lib/modules/`uname -r`/extra/wlan_rtl"
#if [ -e /proc/device-tree/wlan_type ]; then
#        WLAN_TYPE=$(cat /proc/device-tree/wlan_type);
#else
#        WLAN_TYPE="ATH"
#fi
#
#if [ $WLAN_TYPE == "ATH" ]; then
#   echo "ATH - WPS push button"
#   hostapd_cli wps_pbc
#fi
#if [ $WLAN_TYPE == "RTL" ];then
 echo "RTL - WPS push button" >>/dev/kmsg
 iwpriv wlan0 set_mib ps_level=0 
# iwpriv wlan0 stopps 1
 wscd -sig_pbc wlan0
# sleep 30
# iwpriv wlan0 set_mib ps_level=2  #jclee, block wifi sleep 
#    iwpriv wlan0 stopps 0
#fi


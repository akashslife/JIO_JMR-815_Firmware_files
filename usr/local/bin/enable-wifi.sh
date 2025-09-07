#!/bin/sh

WLAN_TYPE=$(cat /proc/device-tree/wlan_type);
WIFI_AUTO_ENABLE=`uci get wifi.wifi_start.auto_enable`

# if [ -e /proc/device-tree/soc/rtl8192_specific/wifi_en ]; then
#   WIFI_EN=$(hexdump /proc/device-tree/soc/rtl8192_specific/wifi_en|awk -F' ' '{print $3}'|sed 's/^0*//')
# else
#    WIFI_EN="ignore"
# fi

if [ -e /proc/device-tree/soc/rtl8192_specific/wowlan_pin ] || [ -e /proc/device-tree/soc/rtl8192_specific/gpios ] ; then
    WOWLAN="enable"
else
    WOWLAN="disable"
fi

#WPS_GPIO_NUM=`cat /proc/device-tree/soc/wps_gpio_num`

INIT_FLAG=/tmp/wifi.init

if [ ! -f $INIT_FLAG ]; then
    touch $INIT_FLAG

    if [ $WIFI_AUTO_ENABLE == "true" ]; then
	#       if [ $WIFI_EN != "ignore" ]; then
	#           if [ ! -d  /sys/class/gpio/gpio$WIFI_EN ] ; then
	#               echo $WIFI_EN > /sys/class/gpio/export
	#           fi
	#           if [ ! -d  /sys/class/gpio/gpio$WIFI_EN ]; then
	#                echo "fail to access wifi_en at "/sys/class/gpio/gpio$WIFI_EN > /dev/kmsg
	#            fi
	#            echo high > /sys/class/gpio/gpio$WIFI_EN/direction
	#        fi

	        wifi-control.sh start
#	        wpsd $WPS_GPIO_NUM #move to pwrt_sm

# 170210, ntmore added, block ps_level disable
#	        if [ $WOWLAN == "disable" ]; then
#	            echo "WoWlan disabled in device tree - disable the feature" > /dev/kmsg
#	            iwpriv wlan0 stopps 1
#	            wifi-control.sh ps_disable
#	        fi
    else
        echo "wifi is not automatic enabled need to change configuration file at /etc/config/wifi"
	fi
fi
wifi-control.sh enable



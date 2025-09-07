#!/bin/sh

check_ap_count0=0
check_ap_count1=0
check_ap_total=0

sleep 3

if [ -f /proc/wlan0/sta_info ];then
	check_ap_count0=`/usr/local/bin/alt_get_conn_stats.sh /proc/wlan0 2 >/dev/null|wc -l`
		if [ -f /proc/wlan0-va0/sta_info ];then
			check_ap_count1=`/usr/local/bin/alt_get_conn_stats.sh /proc/wlan0-va0 2 >/dev/null|wc -l`
		fi
	check_ap_total=`expr $check_ap_count0 + $check_ap_count1`
	

	if [ $check_ap_total == 0 ];then
		echo "none" >/sys/class/leds/Wifi_RED/trigger
		echo "none" >/sys/class/leds/Wifi_GREEN/trigger
		echo "none" >/sys/class/leds/Wifi_BLUE/trigger
		echo "0" >/sys/class/leds/Wifi_RED/brightness
		echo "0" >/sys/class/leds/Wifi_GREEN/brightness
		echo "255" >/sys/class/leds/Wifi_BLUE/brightness
	elif [ $check_ap_total > 1 ];then
		echo "none" >/sys/class/leds/Wifi_RED/trigger
		echo "none" >/sys/class/leds/Wifi_GREEN/trigger
		echo "none" >/sys/class/leds/Wifi_BLUE/trigger
		echo "0" >/sys/class/leds/Wifi_RED/brightness
		echo "0" >/sys/class/leds/Wifi_BLUE/brightness
		echo "255" >/sys/class/leds/Wifi_GREEN/brightness
	fi
else
	echo "none" >/sys/class/leds/Wifi_RED/trigger                        
	echo "none" >/sys/class/leds/Wifi_GREEN/trigger        
	echo "none" >/sys/class/leds/Wifi_BLUE/trigger 
	echo "0" >/sys/class/leds/Wifi_GREEN/brightness
	echo "0" >/sys/class/leds/Wifi_BLUE/brightness
	echo "255" >/sys/class/leds/Wifi_RED/brightness
fi

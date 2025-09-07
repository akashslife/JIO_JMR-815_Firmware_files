#!/bin/sh

#Export the relevent interfaces name
. /usr/local/bin/lte-gw-global-env.sh

        WLAN_TYPE=$(cat /proc/device-tree/wlan_type);

		PM_PATH=/sys/devices/soc.0/b0220200.pm/
PROJECT_TYPE=`cat /proc/device-tree/model`
echo /usr/bin/hotplug.sh > /proc/sys/kernel/hotplug
#jclee,20150414, The other source code are removed.(It related ath6k)

if [ -e /proc/device-tree/wifi ]; then
	RTL_WIFI=`cat /proc/device-tree/wifi`  #jclee, check chipset rtl8192/8189
fi

rtl_start() {
WIFI_ENABLE=`uci get /etc/config/wifi.wifi.wifi_enabled`

if [ $WIFI_ENABLE == "enable" ]; then
    rtl_wlan_modules_dir="/lib/modules/`uname -r`/extra/wlan_rtl"
	INS=`lsmod | grep $RTL_WIFI | awk '{print $1}'`
    if [ -n "$INS" ] ; then
    	rmmod ${RTL_WIFI}es.ko
    fi
	insmod $rtl_wlan_modules_dir/${RTL_WIFI}es.ko

#        echo 0 >/sys/class/leds/Wifi_RED/brightness                                                                                                                 
#        echo 0 >/sys/class/leds/Wifi_GREEN/brightness                                                                                                               
#        echo 255 >/sys/class/leds/Wifi_BLUE/brightness
#        echo none > /sys/class/leds/Wifi_BLUE/trigger
	echo "WIFI_START" > /tmp/pwrt_sm_event_file
    /root/script/init.sh

    if [ -e $PM_PATH/wifi_enable ]
    then
            echo 1 > $PM_PATH/wifi_enable
    else
            echo "note: wifi_enable files does not exist - probably PM is not defined in kernel"
    fi

    iwpriv wlan0 set_mib ps_level=2 #NTmore added, set ps_level

else
	INS=`lsmod | grep $RTL_WIFI | awk '{print $1}'`
    if [ -n "$INS" ] ; then
    	rmmod ${RTL_WIFI}es.ko
    fi
	echo 0 >/sys/class/leds/Wifi_RED/brightness
	echo 0 >/sys/class/leds/Wifi_GREEN/brightness
	echo 0 >/sys/class/leds/Wifi_BLUE/brightness

	echo "wifi disabled" >>/dev/kmsg
fi
}
rtl_stop() {
    ifconfig wlan0 down
    rmmod ${RTL_WIFI}es.ko
if [ $PROJECT_TYPE != "NTLD-200" ];then
    killall -q wscd
fi
    if [ -e $PM_PATH/wifi_enable ]
    then
            echo 0 > $PM_PATH/wifi_enable
    else
            echo "note: wifi_enable files does not exist - probably PM is not defined in kernel"
    fi
}
rtl_enable() {
	ifconfig wlan0 up
    if [ -e $PM_PATH/wifi_enable ]
    then
            echo 1 > $PM_PATH/wifi_enable
    else
            echo "note: wifi_enable files does not exist - probably PM is not defined in kernel"
    fi
}	
rtl_disable() {
	ifconfig wlan0 down
    if [ -e $PM_PATH/wifi_enable ]
    then
            echo 0 > $PM_PATH/wifi_enable
    else
            echo "note: wifi_enable files does not exist - probably PM is not defined in kernel"
    fi
}	

	case "$1" in
    	start)
		iwpriv wlan0 stopps 0
        	rtl_start
            echo ">>> start wifi by wifi control script" > /dev/kmsg
        	;;
    	stop)
        	rtl_stop
            echo ">>> stop wifi by wifi control script" > /dev/kmsg
        	;;
    	disable)
        	rtl_disable
            echo ">>> disable wifi by wifi control script" > /dev/kmsg
        	;;
    	enable)
        	rtl_enable
            echo ">>> enable wifi by wifi control script" > /dev/kmsg
        	;;
        ps_enable)
            iwpriv wlan0 set_mib ps_level=2 
            echo ">>> set wifi ps enable by wifi control script" > /dev/kmsg
            ;;
        ps_disable)
            iwpriv wlan0 set_mib ps_level=0 
            echo ">>> set wifi ps diable by wifi control script" > /dev/kmsg
            ;;
    	restart)
    	$0 stop
    	$0 start
	esac                                  

#!/bin/sh

factory_files="/nvm/bsp/factory"
export MODEL_NAME=`cat /proc/device-tree/model | cut -d - -f2`
export RIL_MODEL="JMR815"
REBOOT_AFTER=0

############################################################################
#       MIGRATION FACTORY FILES                                            #
############################################################################

if [ ! -f $factory_files ]; then

        echo "config 'factory' 'value'">$factory_files

	uci set $factory_files.value.model="JMR815"
	uci set /etc/static-config/Identification.Device.iProduct=$RIL_MODEL
	uci set /etc/static-config/Identification.Model.Model=$RIL_MODEL
	uci commit /etc/static-config/Identification
	sync
	uci set $factory_files.value.bsn="00000000000000"
	uci set $factory_files.value.psn="RNTMF0000000000"
	uci set $factory_files.value.imei="000000000000000"
	uci set $factory_files.value.wifi_mac="00:00:00:00:00:00"
	uci set $factory_files.value.sw_ver="0"
	uci set $factory_files.value.hw_ver="0"
	uci set $factory_files.value.key_test="0"
	uci set $factory_files.value.led_test="0"
	uci set $factory_files.value.cal_test="0"
	uci set $factory_files.value.imei_test="0"
	uci set $factory_files.value.usim_test="0"
	uci set $factory_files.value.mac_test="0"
	uci set $factory_files.value.auto_test="0"
	uci set $factory_files.value.final_test="0"
	uci commit $factory_files
	sync
	sed -i -e '/^$/d' $factory_files
fi


F_MODEL_NAME=`uci get $factory_files.value.model`

if [ `echo $F_MODEL_NAME |wc -L` -eq 0 ];then
	uci set $factory_files.value.model=$RIL_MODEL
	uci set /etc/static-config/Identification.Device.iProduct=$RIL_MODEL
	uci set /etc/static-config/Identification.Model.Model=$RIL_MODEL
	uci commit /etc/static-config/Identification
	sync
	uci commit $factory_files
	sync
fi

############################################################################
#       IMEI WRITE 		                                           #
############################################################################
#
#FACTORY_IMEI=`uci get $factory_files.value.imei`
#FACTORY_IMEI_TEST=`uci get $factory_files.value.imei_test`
#
#if [ $FACTORY_IMEI == "000000000000000" ];then
#
#	echo "No need to set IMEI value" >>/dev/kmsg
#
#elif [ $FACTORY_IMEI_TEST == "0" ];then
#
#		if [ -f /nvm/bsp/dop.default ];then                                                                                                          
#			rm -rf /nvm/bsp/dop.default                                                                                               
#       	fi
#
#		echo "Writing IMEI value" >>/dev/kmsg
#
#		/usr/bin/imei_write $FACTORY_IMEI
#		sync
#			
#		IMEI_AT_TEST=`/etc/ue_lte/at.sh at+gsn | grep -v at+gsn | grep -v OK`
#
#	        if [ $FACTORY_IMEI == $IMEI_AT_TEST ];then
#              		uci set $factory_files.value.imei_test="1"
#              		uci commit $factory_files
#			sync
#		else
#			echo "invalid IMEI value, restore default IMEI values" >>/dev/kmsg
#			uci set $factory_files.value.imei="000000000000000"
#			uci commit $factory_files
#			sync
#		fi
#
#elif [ $FACTORY_IMEI_TEST == "1" ];then
#
#	if [ ! -f /nvm/bsp/dop.default ];then
#		cp -rf /nvm/bsp/dop /nvm/bsp/dop.default
#	fi
#
#else
#	echo "Already Tested IMEI value" >>/dev/kmsg
#
#fi

############################################################################
#       WIFI MAC WRITE                                                     #
############################################################################
MAC_ADDR_CHECK=`uci get /nvm_defaults/etc/config/wifi.wifi.macaddress`
if [ $MAC_ADDR_CHECK == "00:00:00:00:00:00" ];then
	uci set $factory_files.value.mac_test="0"
	uci commit $factory_files
	sync
fi

FACTORY_MAC_TEST=`uci get $factory_files.value.mac_test`
if [ $FACTORY_MAC_TEST == "0" ];then
        FACTORY_MAC=`uci get $factory_files.value.wifi_mac`
        if [ $FACTORY_MAC == "00:00:00:00:00:00" ];then
			echo "No need to set MAC address value" >>/dev/kmsg
        elif [ `echo $FACTORY_MAC |wc -m` -eq 18 ];then
			echo "Writing MAC address value" >>/dev/kmsg

			uci set /etc/config/wifi.wifi.macaddress=$FACTORY_MAC
			uci set /nvm_defaults/etc/config/wifi.wifi.macaddress=$FACTORY_MAC
			uci commit /etc/config/wifi
			uci commit /nvm_defaults/etc/config/wifi

			sync
			############################################################################
			#       LTE MAC WRITE                                             #
			############################################################################

			uci set /etc/static-config/Identification.Device.Lte0LocalMacAdd=$FACTORY_MAC
			uci commit /etc/static-config/Identification
			sync

			############################################################################
			#       WIFI SSID                                                 #
			############################################################################

#			FACTORY_SSID_MAC=`uci get $factory_files.value.wifi_mac | sed -e "s/://g" |cut -c 9-12`
			FACTORY_SSID_MAC=`uci get $factory_files.value.wifi_mac | sed -e "s/://g" |cut -c 7-12`

#			F_MODEL_NAME=`uci get $factory_files.value.model`

#			uci set $factory_files.value.ssid="NTLD-${MODEL_NAME}-$FACTORY_SSID_MAC"
			uci set $factory_files.value.ssid="JioFi_1${FACTORY_SSID_MAC}"
			sync
			FACTORY_SSID=`uci get $factory_files.value.ssid`
			echo "Changing SSID" >>/dev/kmsg
			uci set /etc/config/wifi.wifi.ssid=$FACTORY_SSID
			uci set /nvm_defaults/etc/config/wifi.wifi.ssid=$FACTORY_SSID
			uci commit /etc/config/wifi
			uci commit /nvm_defaults/etc/config/wifi
			sync
			# wifi password writing"

			echo "Changing Password" >>/dev/kmsg
		
			FACTORY_WIFI_PW=`uci get $factory_files.value.wifi_pass`

			if [ $FACTORY_WIFI_PW == "0" ];then

				echo "No need to set wifi PASSWORD, using default value" >>/dev/kmsg


			elif [ `echo $FACTORY_WIFI_PW | wc -L` -eq 10 ]; then

				uci set /etc/config/wifi.wifi.sec_pass=$FACTORY_WIFI_PW
				uci set /nvm_defaults/etc/config/wifi.wifi.sec_pass=$FACTORY_WIFI_PW
				uci commit /etc/config/wifi
				uci commit /nvm_defaults/etc/config/wifi
				sync

				echo "Setting wifi PASSWORD" >>/dev/kmsg
			fi

		        uci commit /etc/config/wifi


			############################################################################
			#       WIFI EXTRA MAC                                            #
			############################################################################
#			if [ -f /etc/config/wifi-second ];then
#				FACTORY_MAC_ORDER_2=`uci get /nvm/bsp/factory.value.wifi_mac | cut -c 13-17`
#				EXTRA_MAC_ADDR="00:01:73:01:${FACTORY_MAC_ORDER_2}"
#				EXTRA_MAC_ADDR_2="00017301${FACTORY_SSID_MAC}"
#				uci set /etc/config/wifi-second.wifi.ssid="NTLR-${MODEL_NAME}-$FACTORY_SSID_MAC-2nd"
#				uci set /nvm_defaults/etc/config/wifi-second.wifi.ssid="NTLR-${MODEL_NAME}-$FACTORY_SSID_MAC-2nd"
#				uci set /etc/config/wifi-second.wifi.macaddress=$EXTRA_MAC_ADDR
#				uci set /nvm_defaults/etc/config/wifi-second.wifi.macaddress=$EXTRA_MAC_ADDR
#				uci commit /etc/config/wifi-second
#				uci commit /nvm_defaults/etc/config/wifi-second
#				echo $EXTRA_MAC_ADDR_2 > /var/rtl8192c/wlan0/nic1_addr
#				echo $EXTRA_MAC_ADDR_2 > /var/rtl8192c/wlan0/wlan1_addr
#				sync
#			fi

		        uci set $factory_files.value.mac_test="1"

		        uci commit $factory_files
			sync
        fi
fi

############################################################################
#       USB MAC WRITE                                             #
############################################################################

USB_CHECK=`uci get /nvm/etc/config/lte.config.host_addr`

if [ $USB_CHECK == "00:11:22:33:44:56" ] || [ $FACTORY_MAC_TEST == "0" ];then

	FACTORY_MAC_TEST=`uci get $factory_files.value.mac_test`

	if [ $FACTORY_MAC_TEST == "1" ] ;then

		USB_MAC_ORDER=`uci get /nvm/bsp/factory.value.wifi_mac | cut -c 7-17`
		USB_MAC=`echo 00:12:"$USB_MAC_ORDER"`
		uci set /etc/static-config/Identification.Device.Usb0HostMacAdd=$USB_MAC
		uci commit /etc/static-config/Identification

		uci set /nvm/etc/config/lte.config.host_addr=$USB_MAC
		uci commit /nvm/etc/config/lte
	
		uci set /nvm_defaults/etc/config/lte.config.host_addr=$USB_MAC
		uci commit /nvm_defaults/etc/config/lte
		sync

	fi
	
	PRODUCT_CHECK=`cat /etc/static-config/Identification | grep "NTLR-310" |wc -l`
	
	if [ $PRODUCT_CHECK -ne 0 ];then
		uci set /etc/static-config/Identification.Model.Model=$RIL_MODEL
		uci set /etc/static-config/Identification.Device.iProduct=$RIL_MODEL
		uci commit /etc/static-config/Identification		
	fi
fi

if [ $REBOOT_AFTER -eq 1 ];then
	fw_setenv reboot 1
	sync
	echo "Factory Value Setting" >/etc/config/reason_start
	echo "Restarting for factory value" >>/dev/kmsg
	reboot
fi

############################################################################
#       HARDWARE REV CHECK                                                 #
############################################################################

HW_VER=`uci get /nvm/bsp/factory.value.hw_ver`

if [ $HW_VER == 0 ]
then

HW_REV0=`cat /sys/class/gpio/gpio26/value`
HW_REV1=`cat /sys/class/gpio/gpio28/value`

  if [ $HW_REV1 == 0 ]
  then
    if [ $HW_REV0 == 0 ]
    then
      uci set /nvm/bsp/factory.value.hw_ver=1.0
    else
      uci set /nvm/bsp/factory.value.hw_ver=1.1
    fi
  else
    if [ $HW_REV0 == 0 ]
    then
      uci set /nvm/bsp/factory.value.hw_ver=1.2
    else
      uci set /nvm/bsp/factory.value.hw_ver=1.3
    fi
  fi
fi

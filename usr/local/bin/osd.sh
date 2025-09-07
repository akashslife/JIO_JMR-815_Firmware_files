#!/bin/sh

#Check for last used OS, if failed run OS detection (based on Mass storage gadget).
#After OS was detected Linux/MAC or Windows based (WIN 7 / XP), run the relevent driver
#If after some timeout (default 30 sec) the OS didnt connect to the device,
#Export the Mass-storage device appers as CDROM in the HOSTS.
usb_gadget_start_osd_ms_mem() {
	local section="$1"
	local osd_timeout="$2"
	local os_type
	local last_os

	#Make sure no gadget is in
	rm_module_if_gadget_exist
	last_os=`uci get usb-gadget.config.last_os`
	use_last_os=`uci get usb-gadget.config.use_last_os`
	#if the parameter does not exist then force detection
	if [ -z "$last_os" ]; then
		last_os='0'
	fi
	#last_os=0
	if [ -z "$use_last_os" ]; then
		# default is to user last OS
		use_last_os='1'
	fi
	
	if [ $last_os -eq $OST_UNKNOWN -o $last_os -eq $OST_POWER_PLUG -o $use_last_os -eq 0 ]; then
		# Detect a OS type
		rm_module_if_gadget_exist
		echo "----------------------------------- OSD required" > /dev/kmsg
		modprobe g_os_detect file=/cdrom.iso stall=0 osd_mode=3 cdrom=1
		osd_poll_os_type ${osd_timeout}
	else
		echo "----------------------------------- OSD not required" > /dev/kmsg
		os_type=$last_os
	fi
	
	start_driver ${section} $os_type
	#The device driver started but reach the timeout
	if [ $RET -ne 0 ];then
		echo "----------------------------------- Failure while loading gadget" > /dev/kmsg
		if [ $last_os -eq 0 ];then
			reset_usb_ctl
			usleep 100000
			start_driver ${section} $os_type
		fi
		#restart diver
		`uci set usb-gadget.config.last_os=0`
		`uci commit usb-gadget.config.last_os`
	else
		#save last succesful OS type
		`uci set usb-gadget.config.last_os=$os_type`
		`uci commit usb-gadget.config.last_os`
	fi

	RET=$os_type
}

restart_osd() {

    echo "------------------------------------ No OS has been found. Reactivating OSD" > /dev/kmsg
    usb_gadget_start_osd_ms_mem ${section} 150
    restart-lan.sh
}






osd_poll_config_type() {
	local retries
	retries=$1
	while [[ $retries -gt  0 ]] ; do 
		echo " retries :  $retries "
		config_type=$(cat /sys/module/g_os_detect/parameters/set_config_val)
		if [ "$config_type" != "0" ]; then
			return
		fi
		usleep 200
		retries=$(($retries -1))
	done;
}

osd_poll_os_type() {
	local retries
	retries=$1
	while [[ $retries -gt  0 ]] ; do 
		echo " retries :  $retries "
		os_type=$(cat /sys/module/g_os_detect/parameters/os_type)
		if [ "$os_type" != "0" ]; then
			return
		fi
		usleep 200
		retries=$(($retries -1))
	done;
#default
	os_type=$OST_POWER_PLUG
}

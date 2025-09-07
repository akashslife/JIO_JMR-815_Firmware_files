#!/bin/sh

start_mass_storage() {
	local section="$1"
	local configtime
	local file

	idproduct=`uci get -c /etc/static-config/ Identification.Device.idProductCdrom`

	config_get iserialnumber "${section}" iSerialNumber
	config_get configtime "${section}" config_time 10
	config_get file "${section}" cdromFile

	rm_module_if_gadget_exist

	modprobe g_mass_storage \
		idVendor="${idvendor}" \
		idProduct="${idproduct}" \
		iManufacturer="${imanufacturer}" \
		iProduct="${iproduct}" \
		iSerialNumber="${iserialnumber}" \
		file="${file}" \
		cdrom=1 \
		stall=0 \
		wait_eject=1

}

start_rndis() {
	local section="$1"
	local iserialnumber
	
	if [ -e /proc/device-tree/sdcard_fs ]; then
        idproduct=`uci get -c /etc/static-config/ Identification.Device.idProductMulti`
    else
        idproduct=`uci get -c /etc/static-config/ Identification.Device.idProductRndis`
    fi
	
	config_get iserialnumber "${section}" iSerialNumber
	config_get configtime "${section}" config_time            
	config_get mtu "${section}" if_mtu

	#WINDOWS 7 first time , timeout should be more then default
	#This should be the second arg
	if [ $# == "2" ]; then
		if [ $2 = "3" ]; then
			# override timeout
			configtime=`uci get -q -c /etc/config/ os-gadget.timeout.windows7`
		fi
	fi


	if [ -e /dev/mmcblk0p1 -a -e /proc/device-tree/sdcard_fs ]; then
		if [ `is_modprobe_required g_multi` == "n" ]; then
			#make caller happy
			RET=0
			return	
		fi
		rm_module_if_gadget_exist
        	modprobe g_multi \
			dev_addr="${device_mac0}" \
			host_addr="${host_mac0}" \
			idVendor="${idvendor}" \
			idProduct="${idproduct}" \
			iManufacturer="${imanufacturer}" \
			iProduct="${iproduct}" \
			iSerialNumber="${iserialnumber}" \
			if_mtu="${mtu}"  \
			file=/dev/mmcblk0p1 \
			stall=0 
	else	
		if [ `is_modprobe_required g_rndis` == "n" ]; then
			#make caller happy
			RET=0
			return	
		fi
		rm_module_if_gadget_exist
		modprobe g_rndis \
			dev_addr="${device_mac0}" \
			host_addr="${host_mac0}" \
			idVendor="${idvendor}" \
			idProduct="${idproduct}" \
			iManufacturer="${imanufacturer}" \
			iProduct="${iproduct}" \
			iSerialNumber="${iserialnumber}" \
			timeout_secs="${configtime}" \
			if_mtu="${mtu}"
	fi
	RET=`echo $?`
}

start_ether() {
	local section="$1"
	local iserialnumber
	local g_driver="g_ether"

	case $2 in
		1|2|3)
		idproduct=`uci get -c /etc/static-config/ Identification.Device.idProductRndis`
		;;

		*)
		idproduct=`uci get -c /etc/static-config/ Identification.Device.idProductGether`
		num_ether_ports=`uci get -q -c /etc/config/ usb-gadget.config.num_ether_ports`
		;;
	esac

    	if [[ -z "$num_ether_ports" ]]; then
        	num_ether_ports=1
    	fi

	config_get iserialnumber "${section}" iSerialNumber
	config_get configtime "${section}" config_time
	config_get mtu "${section}" if_mtu

	#WINDOWS 7 first time , timeout should be more then default
	if [ $2 = "3" ]; then
		# override timeout
		configtime=`uci get -q -c /etc/config/ os-gadget.timeout.windows7`
	fi
	
	# adding 1.5 sec delay found to be required between rmmod of os_detect and the g_ether install
	# problems with g_ether not getting loaded on MacOS where seen without this delay
	# delay time optimization may be possible in the future for boot time reduction but 1sec still showed
	# failure rate
	# usleep 1500000

	if [ -e /dev/mmcblk0p1 -a -e /proc/device-tree/sdcard_fs ]; then
		if [ `is_modprobe_required g_multi` == "n" ]; then
			#make caller happy
			RET=0
			return	
		fi
		rm_module_if_gadget_exist
        	modprobe g_multi \
			dev_addr="${device_mac0}" \
			host_addr="${host_mac0}" \
			idVendor="${idvendor}" \
			idProduct="${idproduct}" \
			iManufacturer="${imanufacturer}" \
			iProduct="${iproduct}" \
			iSerialNumber="${iserialnumber}" \
			if_mtu="${mtu}"  \
			file=/dev/mmcblk0p1 \
			stall=0 
	else	
		if [ `is_modprobe_required g_ether` == "n" ]; then
			#make caller happy
			RET=0
			return	
		fi
		rm_module_if_gadget_exist
		modprobe g_ether \
			dev_addr="${device_mac0},${device_mac1}" \
			host_addr="${host_mac0},${host_mac1}" \
	        n_ether_ports="${num_ether_ports}" \
			idVendor="${idvendor}" \
			idProduct="${idproduct}" \
			iManufacturer="${imanufacturer}" \
			iProduct="${iproduct}" \
			iSerialNumber="${iserialnumber}" \
			timeout_secs="${configtime}" \
			if_mtu="${mtu}" \
			2>&1 >/dev/null
	fi

	RET=`echo $?`
}

usb_gadget_start_osd_composite() {
    local section="$1"
    local osd_timeout="$2"
    local config_type
    local g_driver="g_os_detect"
	
    # Detect a OS type
    echo "++++++++++ 1. OS Detect (Composite/MBIM) +++++++++++" > /dev/kmsg

        if [ `is_modprobe_required $g_driver` == "n" ]; then
		#make caller happy
		RET=0
		return	
	fi
	rm_module_if_gadget_exist

    modprobe $g_driver file=/cdrom.iso stall=0 osd_mode=2 cdrom=1
    osd_poll_config_type ${osd_timeout}
    rm_module_if_gadget_exist
    sleep 1
    if [ $config_type -eq 2 ];then
        echo "++++++++++ 2. Start MBIM driver for Win8 (Config type $config_type) +++++++++++" > /dev/kmsg
        #start_mbim ${section}
        #start_mbim_acm ${section}
        start_mbim_hid ${section}

        #save last detected OS type
        `uci set usb-gadget.config.last_os=6`
        `uci commit usb-gadget.config.last_os`
    elif [ $config_type -eq 1 ];then
        echo "++++++++++ 2. Start Composite driver (Config type $config_type) +++++++++++" > /dev/kmsg
        start_composite ${section}

        #save last detected OS type
        `uci set usb-gadget.config.last_os=1`
        `uci commit usb-gadget.config.last_os`
    fi

    RET=$config_type
}


start_mbim() {
	local section="$1"
	local iserialnumber
	local g_driver="g_mbim"
	
	idproduct=`uci get -c /etc/static-config/ Identification.Device.idProductMbim`
    if [ -z "$idproduct" ];
    then
        idproduct="0x0048"
        echo "MBIM idProductMbim is missing in static config, using $idproduct" > /dev/kmsg
    fi

    TOPOLOGY=`uci get lte-gw.local_param.local_topoloy`
    #lte_mac_addr=`uci get -c /etc/static-config/ Identification.Device.Lte0LocalMacAdd`
    if [ $TOPOLOGY == "bridge" ];
    then
        dst_mac_addr="00:11:11:22:22:33"
    else
        dst_mac_addr="${device_mac}"
    fi
	
	config_get iserialnumber "${section}" iSerialNumber
	config_get configtime "${section}" config_time            
	config_get mtu "${section}" if_mtu

	if [ `is_modprobe_required $g_driver` == "n" ]; then
		#make caller happy
		RET=0
		return	
	fi
	rm_module_if_gadget_exist

	modprobe $g_driver \
		dev_addr="${device_mac0}" \
		host_addr="${host_mac0}" \
		dst_mac_addr="${dst_mac_addr}" \
		idVendor="${idvendor}" \
		idProduct="${idproduct}" \
		iManufacturer="${imanufacturer}" \
		iProduct="${iproduct}" \
		iSerialNumber="${iserialnumber}" \
		timeout_secs="${configtime}" \
		if_mtu="${mtu}"

        RET=`echo $?`
}

start_mbim_hid() {
	local section="$1"
	local iserialnumber
	local g_driver="g_mbim"
	
	idproduct=`uci get -c /etc/static-config/ Identification.Device.idProductMbimHid`
    if [ -z "$idproduct" ];
    then
        idproduct="0x004c"
        echo "MBIM_HID idProductMbimHid is missing in static config, using $idproduct" > /dev/kmsg
    fi

    TOPOLOGY=`uci get lte-gw.local_param.local_topoloy`
    #lte_mac_addr=`uci get -c /etc/static-config/ Identification.Device.Lte0LocalMacAdd`
    if [ $TOPOLOGY == "bridge" ];
    then
        dst_mac_addr="00:11:11:22:22:33"
    else
        dst_mac_addr="${device_mac}"
    fi
	
	config_get iserialnumber "${section}" iSerialNumber
	config_get configtime "${section}" config_time            
	config_get mtu "${section}" if_mtu

	if [ `is_modprobe_required $g_driver` == "n" ]; then
		#make caller happy
		RET=0
		return	
	fi
	rm_module_if_gadget_exist

	modprobe $g_driver \
		dev_addr="${device_mac0}" \
		host_addr="${host_mac0}" \
		dst_mac_addr="${dst_mac_addr}" \
		idVendor="${idvendor}" \
		idProduct="${idproduct}" \
		iManufacturer="${imanufacturer}" \
		iProduct="${iproduct}" \
		iSerialNumber="${iserialnumber}" \
		if_mtu="${mtu}"

        RET=`echo $?`
}

start_mbim_hid_acm() {
	local section="$1"
	local iserialnumber
	local g_driver="g_mbim_hid_acm"
	
	idproduct=`uci get -c /etc/static-config/ Identification.Device.idProductMbimHidAcm`
    if [ -z "$idproduct" ];
    then
        idproduct="0x004d"
        echo "MBIM_HID_ACM idProductMbimHidAcm is missing in static config, using $idproduct" > /dev/kmsg
    fi

    TOPOLOGY=`uci get lte-gw.local_param.local_topoloy`
    #lte_mac_addr=`uci get -c /etc/static-config/ Identification.Device.Lte0LocalMacAdd`
    if [ $TOPOLOGY == "bridge" ];
    then
        dst_mac_addr="00:11:11:22:22:33"
    else
        dst_mac_addr="${device_mac}"
    fi
	
	config_get iserialnumber "${section}" iSerialNumber
	config_get configtime "${section}" config_time            
	config_get mtu "${section}" if_mtu

	if [ `is_modprobe_required $g_driver` == "n" ]; then
		#make caller happy
		RET=0
		return	
	fi
	rm_module_if_gadget_exist

	modprobe $g_driver \
		dev_addr="${device_mac0}" \
		host_addr="${host_mac0}" \
		dst_mac_addr="${dst_mac_addr}" \
		idVendor="${idvendor}" \
		idProduct="${idproduct}" \
		iManufacturer="${imanufacturer}" \
		iProduct="${iproduct}" \
		iSerialNumber="${iserialnumber}" \
		if_mtu="${mtu}"

        RET=`echo $?`
}

start_mbim_acm() {
	local section="$1"
	local iserialnumber
	local g_driver="g_mbim_acm"
	
	idproduct=`uci get -c /etc/static-config/ Identification.Device.idProductMbim_acm`
    if [ -z "$idproduct" ];
    then
        idproduct="0x0049"
        echo "MBIM_ACM idProductMbim_acm is missing in static config, using $idproduct" > /dev/kmsg
    fi

    num_serial_ports=`uci get -q -c /etc/config/ usb-gadget.config.num_serial_ports`
    if [[ -z "$num_serial_ports" ]]; then
        num_serial_ports=1
    fi

    TOPOLOGY=`uci get lte-gw.local_param.local_topoloy`
    #lte_mac_addr=`uci get -c /etc/static-config/ Identification.Device.Lte0LocalMacAdd`
    if [ $TOPOLOGY == "bridge" ];
    then
        dst_mac_addr="00:11:11:22:22:33"
    else
        dst_mac_addr="${device_mac}"
    fi
	
	config_get iserialnumber "${section}" iSerialNumber
	config_get configtime "${section}" config_time            
	config_get mtu "${section}" if_mtu

	if [ `is_modprobe_required $g_driver` == "n" ]; then
		#make caller happy
		RET=0
		return	
	fi
	rm_module_if_gadget_exist

	modprobe $g_driver \
		dev_addr="${device_mac0}" \
		host_addr="${host_mac0}" \
		dst_mac_addr="${dst_mac_addr}" \
        n_ports="${num_serial_ports}" \
		idVendor="${idvendor}" \
		idProduct="${idproduct}" \
		iManufacturer="${imanufacturer}" \
		iProduct="${iproduct}" \
		iSerialNumber="${iserialnumber}" \
		if_mtu="${mtu}"

        RET=`echo $?`
}

start_composite() {
	local section="$1"
	local iserialnumber
	local g_driver="g_eth_acm"

	idproduct=`uci get -c /etc/static-config/ Identification.Device.idProductComposite`
	num_ether_ports=`uci get -q -c /etc/config/ usb-gadget.config.num_ether_ports`
    if [[ -z "$num_ether_ports" ]]; then
        num_ether_ports=1
    fi

    num_serial_ports=`uci get -q -c /etc/config/ usb-gadget.config.num_serial_ports`
    if [[ -z "$num_serial_ports" ]]; then
        num_serial_ports=1
    fi
    
	config_get iserialnumber "${section}" iSerialNumber
	config_get mtu "${section}" if_mtu

	if [ `is_modprobe_required $g_driver` == "n" ]; then
		#make caller happy
		RET=0
		return	
	fi
	rm_module_if_gadget_exist

	modprobe $g_driver \
        dev_addr="${device_mac0},${device_mac1}" \
        host_addr="${host_mac0},${host_mac1}" \
        n_ether_ports="${num_ether_ports}" \
        n_ports="${num_serial_ports}" \
		idVendor="${idvendor}" \
		idProduct="${idproduct}" \
		iManufacturer="${imanufacturer}" \
		iProduct="${iproduct}" \
		iSerialNumber="${iserialnumber}" \
		if_mtu="${mtu}"
}

start_multi() {
	local section="$1"
	local iserialnumber
	local file
	local g_driver="g_multi"

	idproduct=`uci get -c /etc/static-config/ Identification.Device.idProductMulti`

	config_get iserialnumber "${section}" iSerialNumber
	config_get file "${section}" cdromFile

	if [ `is_modprobe_required $g_driver` == "n" ]; then
		#make caller happy
		RET=0
		return	
	fi
	rm_module_if_gadget_exist

	modprobe $g_driver \
		dev_addr="${device_mac}" \
		host_addr="${host_mac}" \
		idVendor="${idvendor}" \
		idProduct="${idproduct}" \
		iManufacturer="${imanufacturer}" \
		iProduct="${iproduct}" \
		iSerialNumber="${iserialnumber}" \
		file="${file}" \
		cdrom=1
}

start_ncm() {
	local section="$1"
	local iserialnumber
	local g_driver="g_ncm"
	
	idproduct=`uci get -c /etc/static-config/ Identification.Device.idProductNcm`
    if [ -z "$idproduct" ];
    then
        idproduct="0x004a"
        echo "NCM idProductNcm is missing in static config, using $idproduct" > /dev/kmsg
    fi
	
	config_get iserialnumber "${section}" iSerialNumber
	config_get configtime "${section}" config_time            
	config_get mtu "${section}" if_mtu

	if [ `is_modprobe_required $g_driver` == "n" ]; then
		#make caller happy
		RET=0
		return	
	fi
	rm_module_if_gadget_exist

	modprobe $g_driver \
		dev_addr="${device_mac0}" \
		host_addr="${host_mac0}" \
		idVendor="${idvendor}" \
		idProduct="${idproduct}" \
		iManufacturer="${imanufacturer}" \
		iProduct="${iproduct}" \
		iSerialNumber="${iserialnumber}" \
		if_mtu="${mtu}"

        RET=`echo $?`
}

start_ncm_acm() {
	local section="$1"
	local iserialnumber
	local g_driver="g_ncm_acm"
	
	idproduct=`uci get -c /etc/static-config/ Identification.Device.idProductNcm_acm`
    if [ -z "$idproduct" ];
    then
        idproduct="0x004b"
        echo "NCM_ACM idProductNcm_acm is missing in static config, using $idproduct" > /dev/kmsg
    fi

    num_serial_ports=`uci get -q -c /etc/config/ usb-gadget.config.num_serial_ports`
    if [[ -z "$num_serial_ports" ]]; then
        num_serial_ports=1
    fi
	
	config_get iserialnumber "${section}" iSerialNumber
	config_get configtime "${section}" config_time            
	config_get mtu "${section}" if_mtu

	if [ `is_modprobe_required $g_driver` == "n" ]; then
		#make caller happy
		RET=0
		return	
	fi
	rm_module_if_gadget_exist

	modprobe $g_driver \
		dev_addr="${device_mac0}" \
		host_addr="${host_mac0}" \
        	n_ports="${num_serial_ports}" \
		idVendor="${idvendor}" \
		idProduct="${idproduct}" \
		iManufacturer="${imanufacturer}" \
		iProduct="${iproduct}" \
		iSerialNumber="${iserialnumber}" \
		if_mtu="${mtu}"

        RET=`echo $?`
}

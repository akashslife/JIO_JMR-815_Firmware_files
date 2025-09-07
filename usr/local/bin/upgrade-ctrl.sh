#!/bin/sh

STATIC_CFG_PATH='/etc/static-config'

upgcmd_test() {
	# implement the UPGCMD test AT command

	#  test the reset cause
	boot_cause=`devmem 0xb4978104 | sed 's/0x//' | sed 's/^[0]*//'`

	# check if lock file exists
	if [ -e /tmp/upg_locked ]; then
		upg_lock=1
	else
		upg_lock=0
	fi

	# decide the upgcmd mode
	if [ -z $boot_cause ] && [ $upg_lock -eq 0 ]; then
		upg_mode=0
	else
		upg_mode=1
	fi

	# check status 
	upg_status=$(uci -q -c $STATIC_CFG_PATH get UpgradeInfo.StatusAndResult.Status)
	if [ -z "$upg_status" ]; then
		upg_status="unknown"
	fi

	upg_exitCode=$(uci -q -c $STATIC_CFG_PATH get UpgradeInfo.StatusAndResult.ExitCode)
	if [ -z "$upg_exitCode" ]; then
		upg_exitCode="unknown"
	fi

	echo "mode=$upg_mode"
	echo "status=$upg_status"
	echo "error=$upg_exitCode"
}


upgcmd_start() {

#  test the reset cause
	boot_cause=`devmem 0xb4978104 | sed 's/0x//' | sed 's/^[0]*//'`

	# check if lock file exists
	if [ -e /tmp/upg_locked ]; then
		upg_lock=1
	else
		upg_lock=0
	fi

	if [ -z $boot_cause ] && [ $upg_lock -eq 0 ]; then

		# Look for desired UA network working mode (static ip/ dhcp client / dhcp deamon)
		# If this is supplied in the AT command itself use it, otherwise look for it in the
		# Upgrade configuration file. if all these fail we default to static ip.
		local network_mode=$1
		if [[ -z "$network_mode" ]]; then
			local network_mode=$(uci -q -c $STATIC_CFG_PATH get UpgradeInfo.LanConfig.Mode)
		fi

		if [[ -z "$network_mode" ]]; then
			local network_mode='static'
		fi

		case $network_mode in
			dhcpc)
			fw_setenv boot_option boot_ua_dhcp
			;;
			static)
			fw_setenv boot_option boot_ua_tftp
			;;
			*)
			ret_val=1
			;;
		esac
	
		if [ $ret_val -eq 0 ]; then	
			fw_setenv en_usb_on_init 1 # Precaution, currently tftp will failt if this env variable is not set.

			# check and update status 
			upg_status=$(uci -q -c $STATIC_CFG_PATH get UpgradeInfo.StatusAndResult)
			if [ -z $upg_status ]; then
				upg_status=$(uci -q -c $STATIC_CFG_PATH set UpgradeInfo.StatusAndResult='group')
			fi
			upg_status=$(uci -q -c $STATIC_CFG_PATH set UpgradeInfo.StatusAndResult.Status='upgrade initiated')
			upg_status=$(uci -q -c $STATIC_CFG_PATH commit UpgradeInfo)
			reboot
		fi
	else
		ret_val=1
	fi
}

process_upgcmd() {

	case $upgcmd in
		"lock")
		touch /tmp/upg_locked
		;;

		"start")
		upgcmd_start $1
		;;

		"?")
		upgcmd_test
		;;
	
		*)
		echo "unsupported upgcmd"
		ret_val=1
		;;
	esac


}

ret_val=0
upgcmd=`echo $1 | tr '[:upper:]' '[:lower:]'`

case $# in
	1)
		process_upgcmd
		;;
	2)
		if [[ ! "$upgcmd" == "start" ]]; then
			ret_val=1
		else
			process_upgcmd $2
		fi
		;;
	*)
		ret_val=1
		;;
esac


exit $ret_val

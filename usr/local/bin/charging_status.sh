#!/bin/sh
#
# Read charging status from Battery Charger I2C device. 
# I2C linux device /dev/i2c-1. Device address= 107 (0x6b). Register 0, bits [4:7].     
. /usr/local/bin/lte-gw-global-env.sh
if [ $PROJECT_TYPE != "PWRT" ]; then
	echo "not PWRT skipping script "$0        
	exit 0
fi
if [ -e /proc/device-tree/wlan_type ]; then
        WLAN_TYPE=$(cat /proc/device-tree/wlan_type);
else
        WLAN_TYPE="ATH"
fi
if [ $WLAN_TYPE == "ATH" ]; then
	STT=$(i2cget -y 1 107 0)
else
	STT=$(i2cget -y 0 107 0)
fi

if [ $? -ne 0 ]; then
	echo "Reading Status Error!"
	exit
fi

MASK=0x70
RES=$((($MASK & $STT)>>4)) 

if [ $WLAN_TYPE == "ATH" ]; then
case $RES in
	0)
		echo "No Valid Source"
	;;
	2)
		echo "USB Ready"
	;;
	4)
		echo "Charging from USB"
	;;
	5)
		echo "Charging Done"
	;;
	7)
		echo "Fault"
	;;
	*)
		echo "NA"
	;;
esac
else
case $RES in
	0)
		echo "Ready"
	;;
	1)
		echo "Charge in Progress"
	;;
	2)
		echo "Charging Done"
	;;
	3)
		echo "Fault"
	;;
	*)
		echo "NA"
	;;
esac
fi
	
	


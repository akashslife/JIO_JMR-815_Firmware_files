#!/bin/sh
#
# Read charge status(capacity) from Battery Gauge I2c device. 
# I2C Linux device /dev/i2c-1. Device address= 85 (0x55). 
# Remaining Capacity Command Code=16/17 (0x0e/0x0f).   
# Full Capacity Command Code=14/15 (0x0c/0x0d).    

#Export the relevent interfaces name
. /usr/local/bin/lte-gw-global-env.sh
if [ -e /proc/device-tree/wlan_type ]; then
        WLAN_TYPE=$(cat /proc/device-tree/wlan_type);
else
        WLAN_TYPE="ATH"
fi

if [ $PROJECT_TYPE != "PWRT" ]; then
	echo "not PWRT skipping script "$0        
	exit 0
fi

FG_CHIPID=85
CHRG_CHIPID=107
FG_I2C_BUS=0
CHRG_I2C_BUS=0

case "$WLAN_TYPE" in
	    "ATH")
		FG_CHIPID=85
		CHRG_CHIPID=107
		FG_I2C_BUS=1
		CHRG_I2C_BUS=1
        ;;
	    "RTL")
		FG_CHIPID=85
		CHRG_CHIPID=107
		FG_I2C_BUS=0
		CHRG_I2C_BUS=0
        ;;
    	*)
    	echo "Error: Invalid WLAN_TYPE - $WLAN_TYPE"
    ;;
esac

is_external_power_connected()
{
	STATUS=$(i2cget -y $CHRG_I2C_BUS $CHRG_CHIPID 0)
	if [ $? -ne 0 ]; then
        	echo "Reading Charger Status Error!"
        	exit
	fi

	CHARGER_TYPE=$(uci get battery_config.charger.charger_type)

	if [ $CHARGER_TYPE == "BQ24261" ]; then
	        STT_MASK=0x30
        	STT_POS=4
	        STT_FAULT=3
        	FAULT_MASK=0x7
	        FAULT_LOW_SUPPLY=2

		CHARGERING_STATUS=$((($STATUS & $STT_MASK) >> $STT_POS))
		if [ $CHARGERING_STATUS -eq $STT_FAULT ]; then
			if [ $(($STATUS & $FAULT_MASK)) -eq $FAULT_LOW_SUPPLY ]; then
				return 1
			fi
		fi
	elif [ $CHARGER_TYPE == "BQ24271" ]; then
		STT_MASK=0x70
		STT_POS=4
		NO_VALID_SOURCE=0

		CHARGERING_STATUS=$((($STATUS & $STT_MASK) >> $STT_POS))
		if [ $CHARGERING_STATUS -eq $NO_VALID_SOURCE ]; then
			return 1
		fi
	else
		echo "Unsupported Charger Type Error!"
		exit
	fi

	return 0
}

is_battery_present()
{
	FLAGS=$(i2cget -y $FG_I2C_BUS $FG_CHIPID 0xa w 2>/dev/null)
	if [ "$FLAGS" == "" ]; then
		return 1
	fi

	BAT_DETECTION=$((($FLAGS & 0x8) >> 3))
	if [ $BAT_DETECTION -ne 1 ]; then
		return 1
	fi

	return 0
}

if ! is_battery_present; then
	printf "     battery level      n/a\n"
	printf "     remaining capacity n/a\n"
	printf "     full capacity      n/a\n"
	printf "     current voltage    n/a\n"
	printf "     time to empty      n/a\n"
	exit
fi

LEVEL=$(i2cget -y $FG_I2C_BUS $FG_CHIPID 0x20 w)
if [ $? -ne 0 ]; then
	echo "Reading Battery Level Error!"
	exit
fi

REMAIN=$(i2cget -y $FG_I2C_BUS $FG_CHIPID 0x10 w)  
if [ $? -ne 0 ]; then
	echo "Reading Remaning Capacity Error!"
	exit
fi

FULL=$(i2cget -y $FG_I2C_BUS $FG_CHIPID 0x12 w)
if [ $? -ne 0 ]; then
	echo "Reading Full Capacity Error!"
	exit
fi

CV=$(i2cget -y $FG_I2C_BUS $FG_CHIPID 0x8 w)  
if [ $? -ne 0 ]; then
	echo "Reading Voltage Error!"
	exit
fi

if is_external_power_connected; then
	TIME_STR="n/a"
else
	TIME=$(i2cget -y $FG_I2C_BUS $FG_CHIPID 0x16 w)
	if [ $? -ne 0 ]; then
        	echo "Reading Time to Empty Error!"
        	exit
	fi

	HOURS=$(($TIME / 60))
	MINUTES=$(($TIME % 60))
	TIME_STR=$(printf "%02d:%02d:00" $HOURS $MINUTES)
fi

printf "     battery level      %d %%\n" $LEVEL
printf "     remaining capacity %d mAh\n" $REMAIN
printf "     full capacity      %d mAh\n" $FULL
printf "     current voltage    %d mV\n" $CV
printf "     time to empty      %s\n" $TIME_STR

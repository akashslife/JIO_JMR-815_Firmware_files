#!/bin/sh

ASSERT_TYPE=$1 

fw_setenv reboot 1
sync

echo "none" >/sys/class/leds/Lte_RED/trigger
echo "none" >/sys/class/leds/Lte_GREEN/trigger
echo "none" >/sys/class/leds/Lte_BLUE/trigger
echo "0" >/sys/class/leds/Lte_RED/brightness
echo "0" >/sys/class/leds/Lte_GREEN/brightness
echo "0" >/sys/class/leds/Lte_BLUE/brightness
echo "timer" >/sys/class/leds/Lte_RED/trigger
echo "timer" >/sys/class/leds/Lte_GREEN/trigger
echo "timer" >/sys/class/leds/Lte_BLUE/trigger
echo "1000" >/sys/class/leds/Lte_RED/delay_on
echo "1000" >/sys/class/leds/Lte_RED/delay_off
echo "1000" >/sys/class/leds/Lte_GREEN/delay_on
echo "1000" >/sys/class/leds/Lte_GREEN/delay_off
echo "1000" >/sys/class/leds/Lte_BLUE/delay_on
echo "1000" >/sys/class/leds/Lte_BLUE/delay_off

echo "" > /dev/kmsg
echo "" > /dev/kmsg
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" > /dev/kmsg
echo ">>> FAILURE: LTE FW assert trigger !!! >>>" > /dev/kmsg
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" > /dev/kmsg
echo "" > /dev/kmsg
echo "" > /dev/kmsg

echo ">>> FAILURE: assert type -  $ASSERT_TYPE !!! >>>" > /dev/kmsg

if [ $ASSERT_TYPE == "0" ]
then
    echo ">>> Non recoverable assert! >>>" > /dev/kmsg
fi

#ntmore added, for prevent Disk Full (nvm)
echo ">>> Remove older logs (CrushDump)... >>>" > /dev/kmsg
rm -f /nvm/CrushDumps/*

echo ">>> Start collecting logs (CrushDump)... >>>" > /dev/kmsg
collect-logs.sh -c
echo ">>> Done! >>>" > /dev/kmsg

# Log to SD Card
LOGTOSDCARD=`uci get /etc/config/service.LogToSDCard.Enabled`

if [ $LOGTOSDCARD = 'true' ]; then

	SD_STATUS=$(cat /tmp/wifi_disk_status);

	echo "1: NO SD Card, 0: WiFi Disk, 3: Mass Storage"
	echo "SD_STATUS value is $SD_STATUS"
	if [ $SD_STATUS == "0" ]
	then
		echo "SD Card was Detected and Crash dump logs are copied to SD Card"
		mkdir -p /mnt/media/CrushDumps
		cp /nvm/CrushDumps/* /mnt/media/CrushDumps/
	fi

fi


if [ $ASSERT_TYPE == "0" ]
then
    RESET_RECOVERY=`uci get service.ErrorHandling.reset`
    if [ $RESET_RECOVERY == "true" ]
    then
        /etc/init.d/S99set_pmic_32Khz_osc stop
	#ntmore added, for reboot
        reboot -f
    fi
fi

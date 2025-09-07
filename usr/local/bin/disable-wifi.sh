#!/bin/sh

#Temp, write to DB directly
db_writer -c wifi_connect off wifi_status off
wifi-control.sh disable

# put NXP in hibernate mode
#echo 1 > /sys/devices/platform/sdhci-nxp-sdio101/hibernate



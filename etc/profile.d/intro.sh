USB_CONNECT=`ifconfig usb0 |grep HWaddr|wc -l`
if [ `cat /proc/device-tree/configuration` == "PWRT" ];then
WIFI_MACADDR=`uci get /nvm/bsp/factory.value.wifi_mac`
fi
IMEI_VALUE=`/etc/ue_lte/at.sh at+gsn | grep -v "gsn" | grep -v "OK"`
MODEL=`uci get /nvm/bsp/factory.value.model`
SW_VER=`uci get /etc/config/version.Config.NTVer`
SW_BASE_VER=`uci get /etc/config/version.Config.Ver`
SW_M_VER=`uci get /etc/config/version.Config.Ver`
SW_UBOOT_VER=`fw_printenv ver| cut -d= -f2`
SW_DATE=`uci get /nvm_defaults/etc/config/version.Config.ReleaseDate`
if [ -b /dev/mmcblk0p1 ];then
SW_SDCARD=`ls -l /dev/mmcblk0p1 |wc -l`
fi
BOOT_NUMBER=`fw_printenv boot_number | cut -d= -f2`
BOOT_DELAY=`fw_printenv bootdelay | cut -d= -f2`
UPTIME_INFO=`uptime`

echo ""
echo "  --------------------------------------------------"
echo "       NOTICE !!!!!!"
echo "       Warnning !!!! This is Production Bank"
echo "  --------------------------------------------------"
echo "  This terminal is for the use of NTmore engineers only."
echo ""
echo "  Model :  $MODEL"
echo "  Software Version:  $SW_VER"
echo "  Software Base Version:  $SW_BASE_VER"
echo "  Software Modem Version:  $SW_M_VER"
echo "  Software Compiled date:  $SW_DATE"
echo "  Software bootloader Version : $SW_UBOOT_VER"
echo ""
echo "  Boot Number:	$BOOT_NUMBER		Boot Delay:     $BOOT_DELAY"
if [ -b /dev/mmcblk0p1 ];then
echo "  SD-CARD : $SW_SDCARD "
fi
echo "  IMEI:	 $IMEI_VALUE"
if [ `cat /proc/device-tree/configuration` == "PWRT" ];then
	echo "  WIFI Macaddress: $WIFI_MACADDR"
fi
echo ""
echo " $UPTIME_INFO"
echo ""

#!/bin/sh


SDCARD_ENABLED=`uci get /etc/config/storage.services.sdcard`

case "$1" in
		sdcard)
		if [ $SDCARD_ENABLED = 'enable' ];then
			/etc/init.d/C25usb-gadget.uci stop
			modprobe g_mass_storage file=/dev/mmcblk0
		fi
                ;;
		usb)
		if [ $SDCARD_ENABLED = 'disable' ];then
			rmmod g_mass_storage
			/etc/init.d/C25usb-gadget.uci start
			ifconfig usb0 up
			brctl addif br0 usb0
			/usr/local/bin/pwrt-os-re-detect.sh &
		fi
		;;
esac

#fi

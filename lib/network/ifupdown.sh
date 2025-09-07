#!/bin/sh
source /etc/functions.sh
source /lib/network/config.sh

case "$2" in
        up|"")
                scan_interfaces
                config_get ifname "$1" ifname
                setup_interface "$ifname"
		echo $ifname > /tmp/$1
        ;;
        down)
                scan_interfaces
                config_get ifname "$1" ifname
                ifconfig "$ifname" 0.0.0.0 down
		rm /tmp/$1
        ;;
        *)
        echo "Usage: "$0" {up|down}"
        exit 1
        ;;
esac

exit 0

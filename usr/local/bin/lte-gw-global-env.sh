#!/bin/sh

if [ -e /proc/device-tree/configuration ]; then
        PROJECT_CONFIGURATION=$(cat /proc/device-tree/configuration);
else
        PROJECT_CONFIGURATION="USBModule"
fi

local WAN_IF="none"
local LAN_IF="none"
local BRIDGE_IF="none"
local DEBUG_IF="none"
local LAN_SECOND_IF="none"
local WLAN_IF="none"

pwrt_config () {
        if [ -e /proc/device-tree/wlan_type ]; then
                WIFI_CHIPSET=$(cat /proc/device-tree/wlan_type);
        else
                WIFI_CHIPSET="ATH"
        fi

        if [ -e /proc/device-tree/pwrt_config ]; then
                if [ $(cat /proc/device-tree/pwrt_config) == "FULL" ];then
                        echo "P/WRT is set to FULL by device tree" > /dev/kmsg
                        PWRT_CONFIG="PWRT_FULL"
                else
                        PWRT_CONFIG="PWRT_USB"
                fi
        else
                PWRT_CONFIG="PWRT_USB"
        fi
}

case "$PROJECT_CONFIGURATION" in
    "USBModule")
        PROJECT_TYPE="USB_DONGLE"
        PWRT_CONFIG="NONE"
        ;;
    "USBDongle")
        PROJECT_TYPE="USB_DONGLE"
        PWRT_CONFIG="NONE"
        ;;
    "PWRT")
        PROJECT_TYPE="PWRT"
        pwrt_config
        ;;
    "WRT")
        PROJECT_TYPE="WRT"
        pwrt_config
        ;;
    "ETHGW")
        PROJECT_TYPE="ETH_GW"
        PWRT_CONFIG="NONE"
        ;;
    "GETHGW")
        PROJECT_TYPE="GETH_GW"
        PWRT_CONFIG="NONE"
        ;;
    *)
    echo "Error: Invalid Project Configuration - $PROJECT_CONFIGURATION"
    ;;
esac

if [ $PWRT_CONFIG == "NONE" ]; then
        WIFI_CHIPSET="none"
fi




# Available TYPES ETH_GW , USB_DONGLE , PWRT , DEV_DEBUGGING
# Available TYPES PWRT_USB , PWRT_ETH , PWRT_FULL, NONE
case "$PROJECT_TYPE" in
    "GETH_GW")
        WAN_IF="lte0"
        LAN_IF="eth0"
        DEBUG_IF="none"
        ;;
    "ETH_GW")
        WAN_IF="lte0"
        LAN_IF="eth0"
        DEBUG_IF="usb0"
        ;;
    "USB_DONGLE")
        WAN_IF="lte0"
        LAN_IF="usb0"
        if [ "`uci get -q -c /etc/config/ usb-gadget.config.num_ether_ports`" == "2" ]; then
            DEBUG_IF="usb1"
        else
            DEBUG_IF="none"
        fi
        ;;
    "DEV_DEBUGGING")
        WAN_IF="usb0"
        LAN_IF="eth0"
        DEBUG_IF="none"
        ;;
    "WRT")
        WAN_IF="lte0"
        WLAN_IF="wlan0"
        if [ $PWRT_CONFIG = "PWRT_ETH" ]; then
            LAN_IF="eth0"
            LAN_SECOND_IF="none"
            DEBUG_IF="usb0"
        elif [ $PWRT_CONFIG = "PWRT_USB" ]; then
            LAN_IF="usb0"
            LAN_SECOND_IF="none"
            DEBUG_IF="none"
        elif [ $PWRT_CONFIG = "PWRT_FULL" ]; then
            LAN_IF="eth0"
            LAN_SECOND_IF="usb0"
            DEBUG_IF="none"
        fi
        ;;
    "PWRT")
        WAN_IF="lte0"
        WLAN_IF="wlan0"
        if [ $PWRT_CONFIG = "PWRT_ETH" ]; then
            LAN_IF="eth0"
            LAN_SECOND_IF="none"
            DEBUG_IF="usb0"
        elif [ $PWRT_CONFIG = "PWRT_USB" ]; then
            LAN_IF="usb0"
            LAN_SECOND_IF="none"
            DEBUG_IF="none"
        elif [ $PWRT_CONFIG = "PWRT_FULL" ]; then
            LAN_IF="eth0"
            LAN_SECOND_IF="usb0"
            DEBUG_IF="none"
        fi
        ;;
    *)
            echo "Error: Invalid Project type - $PROJECT_TYPE"
            DEBUG_IF="usb0"
            ;;
esac

#Bridge is alwayes br0
BRIDGE_IF="br0"

#For use from CLI, dont change
if [ $# -ne 0 ]; then
    case "$1" in
        get)
            echo $PROJECT_TYPE
            ;;
        get-pwrt)
            echo $PWRT_CONFIG
            ;;
        get-wifi-chipset)
            echo $WIFI_CHIPSET
            ;;
        get-lan-if)
            echo $LAN_IF
            ;;
        get-second-lan-if)
            echo $LAN_SECOND_IF
            ;;
        get-debug-if)
            echo $DEBUG_IF
            ;;
        get-bridge-if)
            echo $BRIDGE_IF
            ;;
        get-all-env-params)
            echo $PROJECT_TYPE $PWRT_CONFIG $WAN_IF $LAN_IF $BRIDGE_IF $DEBUG_IF $LAN_SECOND_IF $WLAN_IF $WIFI_CHIPSET
            ;;
    esac
fi


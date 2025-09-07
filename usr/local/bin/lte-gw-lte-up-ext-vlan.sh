#!/bin/sh

#Export the relevent interfaces name
. /usr/local/bin/lte-gw-global-env.sh

PATH=$PATH:/usr/local/bin/

MODE=`uci get lte-gw.local_param.local_topoloy`

IF_NAME=$1 
IP_ADDR=$2
EXT_VLAN_ID=$3
IP_FILE="/tmp/PdnIp-${IF_NAME}.txt"
INTERNET_INTERACE_FILE='/tmp/internet_if.txt'

LTE_MAC_ADDRESS=`uci get -c /etc/static-config/ Identification.Device.Lte0LocalMacAdd`
EXTERNAL_BRIDGE_NAME="br$EXT_VLAN_ID"
EXTERNAL_VLAN_NAME="$LAN_IF.$EXT_VLAN_ID"
BR_MULTICAST=`uci get lte-gw.bridge.multicast`

echo ">>> Define VLAN for external addresses: $IF_NAME >>>" > /dev/kmsg
echo ">>> Got IP address: $IP_ADDR"
echo $IP_ADDR > $IP_FILE


if [ $MODE = "router" ]; then
    echo ">>> ROUTER MODE - External VLAN $EXTERNAL_VLAN_NAME not supported >>>" > /dev/kmsg
    return 0
else

    echo ">>> Connect $IF_NAME and $EXTERNAL_VLAN_NAME to $EXTERNAL_BRIDGE_NAME >>>" > /dev/kmsg

    #Enable LTE MAC Sniffing
    echo 1 > /sys/devices/virtual/net/lte0/ue_fw_enable_auto_mac_addr

    #Tell lte driver on additional external PDN 
    echo $IF_NAME | sed -e "s/^.*\(.\)$/\1/" > /sys/devices/virtual/net/lte0/ue_fw_ext_iface

    #Create bridge
    brctl addbr $EXTERNAL_BRIDGE_NAME
    brctl setfd $EXTERNAL_BRIDGE_NAME 0
    brctl stp $EXTERNAL_BRIDGE_NAME off

    if [ $BR_MULTICAST != "enable" ]; then
        echo 0 > /sys/devices/virtual/net/$EXTERNAL_BRIDGE_NAME/bridge/multicast_snooping
    fi

    #Connect LTE interface to new bridge
    brctl addif $EXTERNAL_BRIDGE_NAME $IF_NAME
    
    #Create LAN side VLAN
    vconfig add $LAN_IF $EXT_VLAN_ID

    #Connect VLAN to bridge
    brctl addif $EXTERNAL_BRIDGE_NAME $EXTERNAL_VLAN_NAME

    #Set MAC address for the bridge interface
    #After the addif the bridge MAC is changed
    ifconfig  $EXTERNAL_BRIDGE_NAME hw ether $LTE_MAC_ADDRESS

    #Bring Bridge, lte if and external vlan UP
    ifconfig $EXTERNAL_BRIDGE_NAME up
    ifconfig $IF_NAME up
    ifconfig $EXTERNAL_VLAN_NAME up

fi

echo "Releasing cached memory" > /dev/kmsg
echo 1 > /proc/sys/vm/drop_caches

#no error reporting
return 0

#!/bin/sh

PATH=$PATH:/usr/local/bin/

#Export the relevent interfaces name
. /usr/local/bin/lte-gw-global-env.sh

MODE=`uci get lte-gw.local_param.local_topoloy`

IF_NAME=$1
EXT_VLAN_ID=$2
IP_FILE='/tmp/PdnIp-$IF_NAME.txt'

EXTERNAL_BRIDGE_NAME="br$EXT_VLAN_ID"
EXTERNAL_VLAN_NAME="$LAN_IF.$EXT_VLAN_ID"

if [ $MODE = "router" ]; then
    echo ">>> ROUTER MODE - External VLAN $EXTERNAL_VLAN_NAME not supported >>>" > /dev/kmsg
    return 0
else
    echo ">>> Disconnect $IF_NAME and $EXTERNAL_VLAN_NAME from $EXTERNAL_BRIDGE_NAME >>>" > /dev/kmsg

    #Unset external PDN vlan from lte driver
    echo $IF_NAME | sed -e "s/^.*\(.\)$/\1/" > /sys/devices/virtual/net/lte0/ue_fw_clr_ext_iface

    #Delete the LTE interface from the bridge.
    brctl delif $EXTERNAL_BRIDGE_NAME $IF_NAME
    #Delete the external PDN from the bridge.
    brctl delif $EXTERNAL_BRIDGE_NAME $EXTERNAL_VLAN_NAME

    #Bring bridge if down
    ifconfig $EXTERNAL_BRIDGE_NAME down

    #Bring lan vlan if down
    ifconfig $EXTERNAL_VLAN_NAME down
    vconfig rem $EXTERNAL_VLAN_NAME

    #Delete bridge
    brctl delbr $EXTERNAL_BRIDGE_NAME

    #Delete the IP file
    rm -f $IP_FILE
fi

#no error reporting.
return 0

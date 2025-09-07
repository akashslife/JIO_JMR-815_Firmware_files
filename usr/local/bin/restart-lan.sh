#!/bin/sh
#
# Restart LAN interface when USB detected
#

PATH=$PATH:/usr/local/bin/

#Export the relevent interfaces name
. /usr/local/bin/lte-gw-global-env.sh

MODE=`uci get lte-gw.local_param.local_topoloy`
LOCAL_IP=`uci get lte-gw.local_param.local_ip_addr`
LOCAL_IP_MASK=`uci get lte-gw.local_param.local_ip_mask`

echo "++++++++++ 4. Activating restart-lan +++++++++++"  > /dev/kmsg

if [ $PROJECT_TYPE == "WRT" ] || [ $PROJECT_TYPE == "PWRT" ]; then
    brctl addif $BRIDGE_IF $LAN_IF $LAN_SECOND_IF
    ifconfig $LAN_IF up
elif [ $MODE = "router" ]; then  
    ifconfig $LAN_IF $LOCAL_IP netmask $LOCAL_IP_MASK up
else
    brctl addif $BRIDGE_IF $LAN_IF
    ifconfig $LAN_IF up
fi



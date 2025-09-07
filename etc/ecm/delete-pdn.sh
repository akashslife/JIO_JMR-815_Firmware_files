#!/bin/sh
#
# delete a specific PDN from the system
#

LTE_DOWN_SCRIPT=/usr/local/bin/lte-gw-lte-down.sh
LTE_DOWN_SCRIPT_EXTERNAL_VLAN=/usr/local/bin/lte-gw-lte-down-ext-vlan.sh

IFNAME=$1
PDN_TYPE=$2
EXT_VLAN_ID=$3
IP_TYPE=$4
IPV4_DGW=$5

TCP_DUMP_EN=`uci get service.TCPDUMP.Enabled | tr -s '[:upper:]' '[:lower:]'`
TCP_DUMP_IF=`uci get service.TCPDUMP.Interface`
TCP_DUMP_LOG_FILE=/tmp/tcpdump.pcap
TCP_DUMP_SCRIPT=/usr/local/bin/tcpDumpOp.sh

delete_external_interface() {

    if [ $EXT_VLAN_ID = "0" ]
    then
        if [ -f ${LTE_DOWN_SCRIPT} ]
        then
            ${LTE_DOWN_SCRIPT} $IFNAME $IP_TYPE $IPV4_DGW
        else
            echo "The ${LTE_DOWN_SCRIPT} script file isn't exist!"
        fi
    else
        if [ -f ${LTE_DOWN_SCRIPT_EXTERNAL_VLAN} ]
        then
            ${LTE_DOWN_SCRIPT_EXTERNAL_VLAN} $IFNAME $EXT_VLAN_ID $IP_TYPE
        else
            echo "The ${LTE_DOWN_SCRIPT_EXTERNAL_VLAN} script file isn't exist!"
        fi
    fi
}

VLAN_NUM=$( echo $IFNAME | sed -e "s/.*\.//" )

#-----------------------------------
# ------ Handling ext PDN  ---------
#-----------------------------------

if [ $PDN_TYPE = "ext" ] # external PDN
then
    delete_external_interface
else
    #Default in disable, for external PDN in router mode we enable it (create-pdn).
    #We need to disable it again.
    echo 0 >  /proc/sys/net/ipv6/conf/$IFNAME/router_solicitations
    echo 0 >  /proc/sys/net/ipv6/conf/$IFNAME/accept_ra
fi

#-------------------------------
# ------ Handling VLAN ---------
#-------------------------------
if [ $VLAN_NUM != "0" ] 
then
    if [ -f "/proc/net/vlan/${IFNAME}" ]
    then # internal PDN delete vlan from here / external from lte-down scripts
        #shutting down the vlan interface
        ifconfig $IFNAME down
        # remove the vlan interface from the system
        vconfig rem $IFNAME
    fi
else
    # delete all IP addresses from the specific interface
    echo 1 > /proc/sys/net/ipv6/conf/$IFNAME/disable_ipv6
    ip -4 address flush dev $IFNAME
fi

#-----------------------------------------
# ------ Handling TCPDUMP 		 ---------
#-----------------------------------------

if [ "$TCP_DUMP_EN" = "true" ] && [ "$TCP_DUMP_IF" = "$IFNAME" ]; then
    $TCP_DUMP_SCRIPT stop
    echo -e "$TCP_DUMP_SCRIPT stop \n " > /dev/kmsg
fi

return 0

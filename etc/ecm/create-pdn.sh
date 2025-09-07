#!/bin/sh
#
# create a specific PDN in the system
#

LTE_UP_SCRIPT=/usr/local/bin/lte-gw-lte-up.sh
LTE_UP_SCRIPT_EXTERNAL_VLAN=/usr/local/bin/lte-gw-lte-up-ext-vlan.sh


WAN_IF="lte0"
IFNAME=$1
PDN_TYPE=$2
EXT_VLAN_ID=$3
IP_TYPE=$4
IPADDR=$5
SUBNET_MASK=$6
DGW=$7
MTU=$8

TCP_DUMP_EN=`uci get service.TCPDUMP.Enabled | tr -s '[:upper:]' '[:lower:]'`
TCP_DUMP_IF=`uci get service.TCPDUMP.Interface`
TCP_DUMP_LOG_FILE=/tmp/tcpdump
TCP_DUMP_SCRIPT=/usr/local/bin/tcpDumpOp.sh

DHCP_DIRFFERED_SCRIPT=/etc/ecm/dhcp-client.sh
DHCP_DIRFFERED_LEASEFILE=/tmp/dhcp_differed_lease

create_external_interface() {

    if [ $EXT_VLAN_ID = "0" ]
    then
        if [ -f ${LTE_UP_SCRIPT} ]
        then
            ${LTE_UP_SCRIPT} $IFNAME $IPADDR $IP_TYPE $DGW $MTU
        else
            echo "The ${LTE_UP_SCRIPT} script file isn't exist!"
        fi
    else
        if [ -f ${LTE_UP_SCRIPT_EXTERNAL_VLAN} ]
        then
            ${LTE_UP_SCRIPT_EXTERNAL_VLAN} $IFNAME $IPADDR $EXT_VLAN_ID $IP_TYPE
        else
            echo "The ${LTE_UP_SCRIPT_EXTERNAL_VLAN} script file isn't exist!"
        fi
    fi
}

assign_IPv4_address() {

    # set the IPv4 address in the interface
    ifconfig $IFNAME $IPADDR netmask $SUBNET_MASK up
    # disable IPv6 support in the interface
    if [ $IP_TYPE = 'IP' ] && [ -f "/proc/sys/net/ipv6/conf/${IFNAME}/disable_ipv6" ]
    then
            echo 1 > /proc/sys/net/ipv6/conf/${IFNAME}/disable_ipv6
    fi
}


VLAN_NUM=$( echo $IFNAME | sed -e "s/.*\.//" )


#-------------------------------
# ------ Handling VLAN ---------
#-------------------------------

if [ $VLAN_NUM != "0" ] 
then
    # if exist vlan interface, remove it.
    if [ -f "/proc/net/vlan/${IFNAME}" ]
    then
        ifconfig $IFNAME down
        vconfig rem $IFNAME
    fi

    vconfig add $WAN_IF $VLAN_NUM
fi

#--------------------------------------
# ------ Handling DHCPV4 mode ---------
#--------------------------------------

# Place holder for DHCPV4 handling

if [ $IPADDR = "0.0.0.0" ] 
then
    ifconfig $IFNAME up
    echo "Call DHCP demon, working in IPv4AddrAlloc mode ($IPADDR)" > /dev/kmsg
    
    MAC_FILE_NAME=`printf /tmp/dhcp_diff_mac_%d $EXT_VLAN_ID`
    OPTS_FILE_NAME=`printf /tmp/dhcp_diff_opts_%d $EXT_VLAN_ID`
    
	if [ -e $MAC_FILE_NAME ]; then
    	EXT_DHCP_MAC=`cat $MAC_FILE_NAME`
	fi
	
	if [ -e $OPTS_FILE_NAME ]; then
    	EXT_DHCP_OPTIONS=`cat $OPTS_FILE_NAME`
	fi

    # Patch to set specific options
    #EXT_DHCP_MAC="0001aaffb911"
    #EXT_DHCP_OPTIONS="-x 0x37:011c02030f060c2b -x 0x3c:30303a41303a30413a3a416972556e697479 -x 0x3d:303030314141464642393131"
    
    if [ -z "$EXT_DHCP_MAC" ]; then
    	echo "$0: DHCP_MAC is not set, using default" > /dev/kmsg
    	udhcpc -t 4 -n -q -S -i $IFNAME -s $DHCP_DIRFFERED_SCRIPT
	else	
		echo "$0: Calling udhcpc with MAC: $EXT_DHCP_MAC and OPTS: $EXT_DHCP_OPTIONS" > /dev/kmsg
    	udhcpc -C -V "" -t 4 -n -q -o -S -M $EXT_DHCP_MAC -i $IFNAME -s $DHCP_DIRFFERED_SCRIPT $EXT_DHCP_OPTIONS 
    fi 

    #Set IPADDR and SUBNET_MASK    
    IPADDR=`uci get -c /tmp/ $DHCP_DIRFFERED_LEASEFILE.leasedata.ip`
    SUBNET_MASK=`uci get -c /tmp/ $DHCP_DIRFFERED_LEASEFILE.leasedata.subnet`

    if [ -z "$IPADDR" ]; then
    	echo "$0: Error - EXT_DHCP_IP_ADDR is not set" > /dev/kmsg
    fi 
    if [ -z "$SUBNET_MASK" ]; then
    	echo "$0: Error - EXT_DHCP_NETMASK is not set" > /dev/kmsg
    fi 
    ifconfig $IFNAME down
fi

#------------------------------------------------------
# ------ Handling ext PDN and IpV4 assignment ---------
#------------------------------------------------------

if [ $PDN_TYPE = "ext" ] # external PDN
then

    echo 0 > /proc/sys/net/ipv6/conf/$IFNAME/disable_ipv6
    create_external_interface

else # not external PDN

    if [ $MTU != 'NULL' ]
    then
    	ifconfig $IFNAME mtu $MTU
    fi
	
    if [ $IP_TYPE = 'IP' ] || [ $IP_TYPE = 'IPV4V6' ]
    then		
	    assign_IPv4_address
    fi

    #when forwarding is enable linux ignors all RS/RA msgs
    echo 0 > /proc/sys/net/ipv6/conf/$IFNAME/forwarding

    #Avoid transmiting and accepting dad on (wan) lte interface 
    echo 0 >  /proc/sys/net/ipv6/conf/$IFNAME/accept_dad
    echo 0 >  /proc/sys/net/ipv6/conf/$IFNAME/dad_transmits

    #Default in disable, for internal PDN we enable it.
    echo 3 >  /proc/sys/net/ipv6/conf/$IFNAME/router_solicitations
    echo 1 >  /proc/sys/net/ipv6/conf/$IFNAME/accept_ra
    echo 0 > /proc/sys/net/ipv6/conf/$IFNAME/disable_ipv6
    ifconfig $IFNAME up
fi

#-----------------------------------------
# ------ Handling TCPDUMP 		 ---------
#-----------------------------------------

if [ "$TCP_DUMP_EN" = "true" ]; then
    if [ "$TCP_DUMP_IF" = "$IFNAME" ]; then
        $TCP_DUMP_SCRIPT start $IFNAME $TCP_DUMP_LOG_FILE
        echo -e "$TCP_DUMP_SCRIPT start $IFNAME $TCP_DUMP_LOG_FILE\n" > /dev/kmsg
    elif [ "$TCP_DUMP_IF" = "lte0" ]; then
        # tcpdump on lte0 is not stopped by delete-pdn.sh. tcpdump on lte0 should be exe only once 
        if [ $(ps | grep -v grep | grep 'tcpdump' -c) -eq 0 ]; then
           $TCP_DUMP_SCRIPT start lte0 $TCP_DUMP_LOG_FILE
           echo -e "$TCP_DUMP_SCRIPT start lte0 $TCP_DUMP_LOG_FILE\n" > /dev/kmsg
        fi 
    fi 
fi

return 0

#!/bin/sh

#Export the relevent interfaces name
. /usr/local/bin/lte-gw-global-env.sh

PATH=$PATH:/usr/local/bin/

MODE=`uci get lte-gw.local_param.local_topoloy`

IF_NAME=$1 
IP_ADDR=$2
IP_TYPE=$3
IPV4_DGW=$4
MTU=$5
IP_FILE="/tmp/PdnIp.txt"
DHCPC_PID_FILE="/var/run/udhcpc.pid"
UDHCPC_SCRIPT_NAME="/usr/local/bin/udhcpc.script"
INTERNET_INTERACE_FILE='/tmp/internet_if.txt'
LOGS_DIRECT_SCRIPT='/etc/ue_lte/relayDbgInterfaces.sh'

PDN_SHARING=`uci get lte-gw.bridge.pdn_sharing`

echo ">>> Define VLAN for external addresses: $IF_NAME >>>" > /dev/kmsg

echo ">>> Allocated address: $IP_ADDR"
echo $IP_ADDR > $IP_FILE
echo $IF_NAME > $INTERNET_INTERACE_FILE
#------------------------------

mbim_add_static_arp()
{
    HOST_MAC=`uci get -c /etc/static-config/ Identification.Device.Usb0HostMacAdd`
    echo "Adding static ARP $IP_ADDR $HOST_MAC" > /dev/kmsg
    arp -s $IP_ADDR $HOST_MAC > /dev/kmsg 2>&1
}

is_contains_mbim()
{
    STR_CHECK=$1
    case "$STR_CHECK" in
    *mbim*) echo 1 ;;
    *) echo 0 ;;
    esac
}

bridge_async_conf()
{
    LOCAL_IP=`uci get lte-gw.local_param.local_ip_addr`
    LOCAL_SUBNET=`uci get lte-gw.local_param.local_ip_mask`
    LOGS_IF_ADDR=`uci get lte-gw.debug_param.static_host_ip_addr`
    LOGS_MODE=`uci get lte-gw.modem_fw_logs.logs_mode`
    DHCP_SRV_ENABLE=`uci get lte-gw.dhcp_srv.dhcp_enable`
    USB_IF=`uci get usb-gadget.config.usb_if`

    # Trigger new DHCP request from the host
    if [ $DHCP_SRV_ENABLE == "enable" ]
    then
        #Kill dnsmasq of the bridge here...
        /usr/local/bin/dhcp-ctrl.sh stop


        #Droping ICMP, forcing the host to send DHCP Req
        icmp-control.sh disable 

        #Droping/load the ETH, so the client will ask for DHCP
        if [ $LAN_IF == "eth0" ]; then
         
            #Bring the LTE interface up after we stop the dhcp server
            ifconfig $IF_NAME up
            
            eth-phy-control.sh restart-aneg
        fi

        #Droping/load the USB, so the client will ask for DHCP
        if [ $LAN_IF == "usb0" ]; then
        
            ifconfig $LAN_IF down
           
            #Bring the LTE interface up after we stop the dhcp server
            ifconfig $IF_NAME up

            sleep 1

            ifconfig $LAN_IF up
        fi

        icmp-control.sh enable 10 &
    else #dhcp disabled
        ifconfig $IF_NAME up
    fi

    #Flushing the two conntrack tables
    conntrack -F > /dev/null 2>&1
    conntrack -F expect > /dev/null 2>&1

    if [ $PDN_SHARING == "enable" ] 
    then
	if [ $IP_TYPE = 'IP' ] || [ $IP_TYPE = 'IPV4V6' ]
	then
	        #PDN Sharing support
	        #Add NAT rule for bridge sharing , don't SNAT local traffic and LTE IP address. 
	        iptables -t nat -I POSTROUTING 1 -s $IP_ADDR  -o $BRIDGE_IF -j ACCEPT
	        iptables -t nat -I POSTROUTING 2 -s $LOCAL_IP -o $BRIDGE_IF -d $IP_ADDR -j ACCEPT
	        iptables -t nat -I POSTROUTING 3 -s $LOCAL_IP -o $BRIDGE_IF -d $LOCAL_IP/$LOCAL_SUBNET -j ACCEPT
	        iptables -t nat -I POSTROUTING 4 -s $LOCAL_IP -o $BRIDGE_IF -j SNAT --to-source $IP_ADDR
	        
		#Add default route
                ip ro add $IPV4_DGW dev $BRIDGE_IF
	        ip ro replace default dev $BRIDGE_IF via $IPV4_DGW src $LOCAL_IP
	fi
    fi

    #For bridge mode , we need to add ip route to eth0 for the client ip.
    if [ -n $IP_ADDR ]; then 
        ip route add $IP_ADDR dev $BRIDGE_IF src $LOCAL_IP
    fi

    #These rules should allow access to the bridge IP from within the LAN side although it is on a different network.
    ebtables -t nat -A PREROUTING -p ipv4 --ip-dst $LOCAL_IP -j redirect --redirect-target ACCEPT

    # restart socat based AT commands channel
    # incase the socat does not exist - send warning
    if [ `ps | grep socat | grep atsw0 | awk '{print $1}' | wc -l` != 0 ] ; then 
        ps | grep socat | grep atsw0 | awk '{print $1}' | xargs kill -9 ; 
    else 
        echo "warning, cant find atsw0 socat"; > /dev/kmsg
    fi

    DEFINED_GADGET_FOR_WIN8=`uci get os-gadget.gadget.windows8`
    LAST_OS_DETECT=`uci get usb-gadget.config.last_os`
    OST_WIN_8="6"
    if [ `is_contains_mbim $USB_IF` == 1 ] || [ $LAST_OS_DETECT == $OST_WIN_8 -a `is_contains_mbim $DEFINED_GADGET_FOR_WIN8` == 1 ];then
        mbim_add_static_arp
    fi
    # restart the debug logs in case of bridge and switch of host IP address (only if "logs to host" enabled and no fixed IP)
    # do it only if not eth gw , since eth gw has the usb dedicated to logs with static ip anyway
    if [ $PROJECT_TYPE == "ETH_GW" ]; then
        echo "do not change logs relay in case of ETHGW" > /dev/kmsg
    else
        if [ "$LOGS_IF_ADDR" == "none" -a $LOGS_MODE == "external" ];then
            ${LOGS_DIRECT_SCRIPT} restart $IP_ADDR
        fi
    fi

    echo "Releasing cached memory" > /dev/kmsg
    echo 1 > /proc/sys/vm/drop_caches
}

ipv6_async_conf()
{
    if [ $PROJECT_TYPE == "WRT" ] || [ $PROJECT_TYPE == "PWRT" ]
    then
        lan_configure_ipv6.sh connect $IF_NAME $BRIDGE_IF
    else
        lan_configure_ipv6.sh connect $IF_NAME $LAN_IF
    fi
    if [ $? -ne 0 ]; then
        echo "Error calling lan_configure_ipv6.sh connect $IF_NAME" > /dev/kmsg
    fi
}

if [ $MODE = "router" ]; then  

    #when forwarding is enable linux ignors all RS/RA msgs
    echo 0 >  /proc/sys/net/ipv6/conf/$IF_NAME/forwarding
    
    #Avoid transmiting and accepting dad on (wan) lte interface 
    echo 0 >  /proc/sys/net/ipv6/conf/$IF_NAME/accept_dad
    echo 0 >  /proc/sys/net/ipv6/conf/$IF_NAME/dad_transmits

    #Default is disable, for external PDN in router mode we enable it.
    echo 3 >  /proc/sys/net/ipv6/conf/$IF_NAME/router_solicitations
    echo 1 >  /proc/sys/net/ipv6/conf/$IF_NAME/accept_ra

    if [ $MTU != 'NULL' ]
    then
    	ifconfig $IF_NAME mtu $MTU
    fi
		
    #for ipv6 only we dont need to run the below code
    if [ $IP_TYPE = 'IP' ] || [ $IP_TYPE = 'IPV4V6' ]
    then
        echo "lte-gw-lte-up.sh: running udhcp client!" > /dev/kmsg
        udhcpc -S --pidfile $DHCPC_PID_FILE -i $IF_NAME -O sipsrv -s $UDHCPC_SCRIPT_NAME > /dev/null 2>&1 &

        nat-conf.sh 
        vpn-passthrough-conf.sh $IF_NAME
    else
	#For IPv6 only interface (in ipv4 it is done using the udhcpc script)
	ifconfig $IF_NAME up
    fi
    #Flushing the two conntrack tables
    conntrack -F > /dev/null 2>&1
    conntrack -F expect > /dev/null 2>&1

    #When working with ipv6 in router mode, we need to configure the lan interface and RA msg
    if [ $IP_TYPE = 'IPV6' ] || [ $IP_TYPE = 'IPV4V6' ]
    then
        # Set the firewall rule of IPv6, NTmore added
        /usr/local/bin/firewall6-control.sh

        ipv6_async_conf &
    fi
    

    #Tuning the conntrack table.        
    echo 1200 > /proc/sys/net/netfilter/nf_conntrack_tcp_timeout_established
    echo 4096 > /proc/sys/net/netfilter/nf_conntrack_max
    echo 1024 > /sys/module/nf_conntrack/parameters/hashsize

    echo "Releasing cached memory" > /dev/kmsg
    echo 1 > /proc/sys/vm/drop_caches &
	#jclee, add for wan status [START]	
    /usr/local/bin/wan-status.sh defconfig
    /usr/local/bin/wan-status.sh renew
	#jclee, add for wan status [END]
    if [ $IP_TYPE = 'IPV6' ] || [ $IP_TYPE = 'IPV4V6' ]
    then
        /usr/local/bin/clat.sh start &
    fi
else
    echo ">>> Connect $IF_NAME to bridge! >>>" > /dev/kmsg
    
    LTE_MAC_ADDRESS=`uci get -c /etc/static-config/ Identification.Device.Lte0LocalMacAdd`
    BR_MULTICAST=`uci get lte-gw.bridge.multicast`

    #Enable LTE MAC Sniffing
    VLAN_NUM=$( echo $IF_NAME | sed -e "s/^.*\(.\)$/\1/" )
    echo 1 > /sys/devices/virtual/net/lte0/ue_fw_enable_auto_mac_addr
    echo $VLAN_NUM > /sys/devices/virtual/net/lte0/ue_fw_ext_iface


    #LTE driver answer ARPs for default gateway only
    if [ $PDN_SHARING == "enable" ]
    then
        if [ $IP_TYPE = 'IP' ] || [ $IP_TYPE = 'IPV4V6' ]
        then
		echo $VLAN_NUM $IPV4_DGW  > /sys/devices/virtual/net/lte0/ue_fw_arp_default_gw_set
	fi
    fi

    brctl addif $BRIDGE_IF $IF_NAME
    brctl setfd $BRIDGE_IF 0

    #Set MAC address for the bridge interface
    #After the addif the bridge MAC is changed
    ifconfig  $BRIDGE_IF hw ether $LTE_MAC_ADDRESS

    if [ $BR_MULTICAST != "enable" ]; then
        echo 0 > /sys/devices/virtual/net/$BRIDGE_IF/bridge/multicast_snooping
    fi

    bridge_async_conf &

    IB_EMBMS=`uci get lte-gw.embms.inband_enable`
    if [ $IB_EMBMS = "enable" ]
    then
        if [ $VLAN_NUM = "0" ]
        then
            VLAN_NUM='1'
        fi
        # configure LTE driver to send eMBMS packets (cid 255) to main WAN interface (lte0):
        # echo <cid> <vlan id> <enable>
        echo 255 $VLAN_NUM 1 > /sys/devices/virtual/net/lte0/ue_fw_static_cid_to_vlanid_override
    fi
fi

FTR_DNS_REDIRECT=`uci get lte-gw.net_param.dns_redirect`
if [ $FTR_DNS_REDIRECT = "enable" ]; then
    dns-redirect.sh disable
fi

CAPTIVE_EN=`uci get captive_portal.config.services`

if [ -n "$CAPTIVE_EN" ] && [ $CAPTIVE_EN == "enable" ]
then
    /usr/local/bin/captive_enable.sh
fi

echo "lte-gw-lte-up.sh done!" > /dev/kmsg

#no error reporting
return 0

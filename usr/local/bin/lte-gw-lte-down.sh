#!/bin/sh

PATH=$PATH:/usr/local/bin/

#Export the relevent interfaces name
. /usr/local/bin/lte-gw-global-env.sh

MODE=`uci get lte-gw.local_param.local_topoloy`
LOCAL_IP=`uci get lte-gw.local_param.local_ip_addr`
LOCAL_SUBNET=`uci get lte-gw.local_param.local_ip_mask`
DHCPC_PID_FILE="/var/run/udhcpc.pid"
IP_FILE='/tmp/PdnIp.txt'
IF_NAME=$1
IP_TYPE=$2
IPV4_DGW=$3


mbim_remove_static_arp()
{
    echo "Removing static ARP $IP_ADDR" > /dev/kmsg
    ip_addr=`cat $IP_FILE`
    if [ -n $ip_addr ]; then 
        arp -d $IP_ADDR > /dev/kmsg 2>&1
    fi

    host_mac=`uci get -c /etc/static-config/ Identification.Device.Usb0HostMacAdd`
    echo "Adding static ARP $ip_addr $host_mac" > /dev/kmsg
    ip_addr=`uci get lte-gw.dhcp_srv.range_from_ip`
    arp -s $ip_addr $host_mac > /dev/kmsg 2>&1
}

bridge_async_conf() {
    DHCP_SRV_ENABLE=`uci get lte-gw.dhcp_srv.dhcp_enable`
    USB_IF=`uci get usb-gadget.config.usb_if`


    #Removing these rules should allow access to the bridge IP from within the LAN side. 
    ebtables -t nat -D PREROUTING -p ipv4 --ip-dst $LOCAL_IP -j redirect --redirect-target ACCEPT

    ip_addr=`cat $IP_FILE`
    #For bridge mode , we need to delete ip route to eth0 for the client ip.
    if [ -n $ip_addr ]; then 
        ip route del $ip_addr dev $BRIDGE_IF src $LOCAL_IP
    fi

    #LTE driver answer ARPs for default gateway only
    PDN_SHARING=`uci get lte-gw.bridge.pdn_sharing`
    if [ $PDN_SHARING == "enable" ]
    then
        if [ $IP_TYPE = 'IP' ] || [ $IP_TYPE = 'IPV4V6' ]
        then
    		iptables -t nat -D POSTROUTING -s $LOCAL_IP -o $BRIDGE_IF -j SNAT --to-source $ip_addr
                iptables -t nat -D POSTROUTING -s $LOCAL_IP -o $BRIDGE_IF -d $ip_addr -j ACCEPT
                iptables -t nat -D POSTROUTING -s $LOCAL_IP -o $BRIDGE_IF -d $LOCAL_IP/$LOCAL_SUBNET -j ACCEPT
                iptables -t nat -D POSTROUTING -s $ip_addr  -o $BRIDGE_IF -j ACCEPT


	        VLAN_NUM=$( echo $IF_NAME | sed -e "s/^.*\(.\)$/\1/" )
	        echo $VLAN_NUM  > /sys/devices/virtual/net/lte0/ue_fw_arp_default_gw_del
                ip ro del default 
                ip ro del $IPV4_DGW dev $BRIDGE_IF
		
	fi
    fi


    if [ $DHCP_SRV_ENABLE == "enable" ]
    then
        #load dnsmasq of the bridge here...
        /usr/local/bin/dhcp-ctrl.sh start

        #Droping ICMP, forcing the host to send DHCP Req
        #icmp-control.sh disable 

        #Droping/load the ETH/USB, so the client will ask for DHCP
        if [ $LAN_IF = "eth0" ]; then
            eth-phy-control.sh restart-aneg
        else
        if [ $LAN_IF == "usb0" ]; then
               ifconfig $LAN_IF down
               sleep 1
               ifconfig $LAN_IF up
            fi
        fi

        #Enable ICMP in 10 sec...
        #icmp-control.sh enable 10 &
    fi

    if [ $USB_IF == "mbim" -o $USB_IF == "mbim_acm" ];then
        mbim_remove_static_arp
    fi

    #Delete the IP file
    rm -f $IP_FILE
}

ipv6_async_conf()
{
    if [ $PROJECT_TYPE == "WRT" ] || [ $PROJECT_TYPE == "PWRT" ]
    then
        lan_configure_ipv6.sh disconnect $IF_NAME $BRIDGE_IF
    else
        lan_configure_ipv6.sh disconnect $IF_NAME $LAN_IF
    fi
    
    if [ $? -ne 0 ]; then
        echo "Error calling lan_configure_ipv6.sh disconnect $IF_NAME" > /dev/kmsg
    fi
}

if [ $MODE = "router" ]; then

    if [ $IP_TYPE = 'IPV6' ] || [ $IP_TYPE = 'IPV4V6' ]
    then
        ipv6_async_conf &
    fi

    #Do this only when ipv4 is used
    if [ $IP_TYPE = 'IP' ] || [ $IP_TYPE = 'IPV4V6' ]
    then
        /usr/local/bin/dhcp-ctrl.sh refresh
        #Kill / stop udhcpc on the interface
        DHCPC_PID=`cat $DHCPC_PID_FILE`
        kill $DHCPC_PID
    fi

    #Default in disable, for external PDN in router mode we enable it (lte-up).
    #We need to disable it again.
    echo 0 >  /proc/sys/net/ipv6/conf/$IF_NAME/router_solicitations
    echo 0 >  /proc/sys/net/ipv6/conf/$IF_NAME/accept_ra

    #Flush the device IP address
    #This will also delete default route
    ip address flush dev $1

    #Flush NAT tables
    iptables -t nat -F
    iptables -t mangle -F
    iptables -t filter -F
    
    #Flushing the two conntrack tables
    conntrack -D -g > /dev/null 2>&1
    conntrack -D -n > /dev/null 2>&1
    if [ $IP_TYPE = 'IPV6' ] || [ $IP_TYPE = 'IPV4V6' ]
    then
        /usr/local/bin/clat.sh stop &
    fi	
else 
    echo ">>> Disconnect $IF_NAME from bridge! >>>" > /dev/kmsg
    ETH_MAC_ADDRESS=`uci get -c /etc/static-config/ Identification.Device.Eth0LocalMacAdd`
    USB_MAC_ADDRESS=`uci get -c /etc/static-config/ Identification.Device.Usb0LocalMacAdd`

    #delete the intenet PDN from the bridge.
    brctl delif $BRIDGE_IF $IF_NAME

    #Unset external PDN vlan from lte driver
    echo $IF_NAME | sed -e "s/^.*\(.\)$/\1/" > /sys/devices/virtual/net/lte0/ue_fw_clr_ext_iface

    #Set MAC address for the bridge interface
    #After the delif the bridge MAC is changed
    if [ $LAN_IF = "eth0" ]; then
        ifconfig  $BRIDGE_IF hw ether $ETH_MAC_ADDRESS
    elif [ $LAN_IF = "usb0" ]; then
        ifconfig  $BRIDGE_IF hw ether $USB_MAC_ADDRESS
    fi

    bridge_async_conf &
fi

FTR_DNS_REDIRECT=`uci get lte-gw.net_param.dns_redirect`
if [ $FTR_DNS_REDIRECT = "enable" ]; then
    dns-redirect.sh enable
fi

#no error reporting.
return 0

#!/bin/sh

# $1 action
# $2 lte interface name
# $3 lan interface name
IPV6_LTE_ADDRESS=""
IPV6_LAN_ADDRESS=""
NUM_OF_SEC_TO_WAIT_FOR_ADDR=10
SCRIPT_NAME=`basename $0`
LTE_IF_NAME=$2
LAN_IF_NAME=$3
DHCLIENT_CONF_FILE="/etc/dhclient.conf"
DHCLIENT_CONF_MAP_T_FILE="/etc/dhclient.map_t.conf"
DHCLIENT_PID_FILE="/tmp/dhclient.pid"
DHCLIENT_LEASE_FILE="/tmp/dhclient.lease"
DHCLIENT_LOG_FILE="/tmp/dhclient.log"

DHCPD_CONF_FILE="/tmp/dhcpd.conf"
DHCPD_PID_FILE="/tmp/dhcpd.pid"
DHCPD_LOG_FILE="/tmp/dhcpd.log"

DHCPV6_PD_FILE="/tmp/ip6-pd-info"

IPV6_DROUTE_METRIC=10

get_ipv6_addr_from_interface()
{
    local COUNTER=0
 
    echo "$SCRIPT_NAME Looking for Global IPv6 adderss on $LTE_IF_NAME" > /dev/kmsg
 
    while [  $COUNTER -lt $NUM_OF_SEC_TO_WAIT_FOR_ADDR  ]; do
        IPV6_LTE_ADDRESS=`/sbin/ip addr show $LTE_IF_NAME | grep -i global | awk '/inet6/ {print $2}' | cut -f1 -d'/'`
        if [ -n "$IPV6_LTE_ADDRESS" ]; then
                echo "$SCRIPT_NAME Found Global IPv6 adderss $IPV6_LTE_ADDRESS on $LTE_IF_NAME" > /dev/kmsg
				echo "$IPV6_LTE_ADDRESS" > /tmp/PdnIpV6.txt
                break      
        fi

        sleep 1
        let COUNTER=COUNTER+1
    done

}

get_dhcpv6_param()
{
    echo "get_dhcpv6_param"
    #Check if to recive dns address from dhcp / LTE NAS (at cmd)
    #Check regarding M / O RA flasgs
    #Check regarding MTU

}

#Create ipv6 anycast address
move_ipv6_address_form_lte_to_lan()
{
    if [ -n "$IPV6_LTE_ADDRESS" ]; then
        IPV6_LTE_ADDRESS_128=$IPV6_LTE_ADDRESS"/128"
		IPV6_LTE_ADDRESS_64=$IPV6_LTE_ADDRESS"/64"
        remove_ipv6_from_lan

        #change lte address from /64 to /128  
        echo "$SCRIPT_NAME Change $LTE_IF_NAME IPv6 adderss to $IPV6_LTE_ADDRESS_128" > /dev/kmsg

        #We dont want SLLAC anymore now - we are going to remove SLLAC address
        #And use our /128 static IP
        echo 0 >  /proc/sys/net/ipv6/conf/$LTE_IF_NAME/router_solicitations
        echo 0 >  /proc/sys/net/ipv6/conf/$LTE_IF_NAME/accept_ra

        /sbin/ip addr del $IPV6_LTE_ADDRESS_64 dev $LTE_IF_NAME 2>/dev/null
        /sbin/ip addr del $IPV6_LTE_ADDRESS_128 dev $LTE_IF_NAME 2>/dev/null

        /sbin/ip addr add $IPV6_LTE_ADDRESS_128 dev $LTE_IF_NAME
        
        get_dhcpv6_param

        set_ipv6_default_route

        configure_ipv6_param_for_lan

        #This will trigger RA from the LAN interface - we want to
        #get other parameters before sending RA (e.g dns server) 
        echo "$SCRIPT_NAME Set $LAN_IF_NAME IPv6 adderss to $IPV6_LTE_ADDRESS_64" > /dev/kmsg
        /sbin/ip addr add $IPV6_LTE_ADDRESS_64 dev $LAN_IF_NAME

        #in case the lte interface recived RA with on-link flag on
        #Linux will add a route rule on the lte interface
        #We want this route to have higher priority (/64 to LAN)
        /sbin/ip route add $IPV6_LTE_ADDRESS_64 dev $LAN_IF_NAME metric $IPV6_DROUTE_METRIC
    else
        echo "$SCRIPT_NAME Error: IPV6_LTE_ADDRESS is empty !" > /dev/kmsg
        exit 1
    fi

}

set_ipv6_default_route ()
{
    IPV6_DEFAULT_ROUTE_DST=`/sbin/ip -6 route | grep default | grep kernel | grep $LTE_IF_NAME | awk '{print $3}'`
    if [ -n "$IPV6_DEFAULT_ROUTE_DST" ]; then
        echo "$SCRIPT_NAME Found IPv6 default route for $LTE_IF_NAME - $IPV6_DEFAULT_ROUTE_DST" > /dev/kmsg
        /sbin/ip -6 route add default via $IPV6_DEFAULT_ROUTE_DST dev $LTE_IF_NAME metric $IPV6_DROUTE_METRIC hoplimit 255
        echo "$SCRIPT_NAME calling /sbin/ip -6 route add default via $IPV6_DEFAULT_ROUTE_DST dev $LTE_IF_NAME metric $IPV6_DROUTE_METRIC hoplimit 255" > /dev/kmsg
    else
        echo "$SCRIPT_NAME Error: IPV6_DEFAULT_ROUTE_DST is empty" > /dev/kmsg
    fi
}

remove_ipv6_from_lan()
{
    IPV6_LAN_ADDRESS=`/sbin/ip addr show $LAN_IF_NAME | grep -i global | awk '/inet6/ {print $2}'`
    echo "$SCRIPT_NAME Looking for Global IPv6 adderss on $LAN_IF_NAME" > /dev/kmsg

    if [ -n "$IPV6_LAN_ADDRESS" ]; then
        echo "$SCRIPT_NAME Found Global IPv6 adderss $IPV6_LAN_ADDRESS on $LAN_IF_NAME" > /dev/kmsg
        #First delete the route rule we added before (if we dont - one of the lan/64 route rule will stay on the interface
        # (Linux remove just one /64 route rule).
        /sbin/ip route del $IPV6_LAN_ADDRESS dev $LAN_IF_NAME metric $IPV6_DROUTE_METRIC
        /sbin/ip addr del $IPV6_LAN_ADDRESS dev $LAN_IF_NAME
    else
        echo "$SCRIPT_NAME: IPV6_LAN_ADDRESS is empty" > /dev/kmsg
    fi
}

configure_ipv6_param_for_lan()
{
    echo "configure_ipv6_parm_for_lan"
    #configure dnsmasq with params
}


start_dhclient()
{
    echo "start_dhclient" > /dev/kmsg
    #clear/create lease file
    echo "" > $DHCLIENT_LEASE_FILE
    MAP_T_MODE=`uci get lte-gw.ipv6_config.map_t_opt_from_dhcp`
    if [ $MAP_T_MODE = "enable" ]
    then
        #We need to use special config file with map-t options
        dhclient -6 -P -d -v -cf $DHCLIENT_CONF_MAP_T_FILE  -pf $DHCLIENT_PID_FILE -lf $DHCLIENT_LEASE_FILE $LTE_IF_NAME >> $DHCLIENT_LOG_FILE 2>&1  &
    else
        #Use plain config file
        dhclient -6 -P -d -v -cf $DHCLIENT_CONF_FILE  -pf $DHCLIENT_PID_FILE -lf $DHCLIENT_LEASE_FILE $LTE_IF_NAME >> $DHCLIENT_LOG_FILE 2>&1  &
    fi
}


stop_dhclient()
{
    echo "stop_dhclient" > /dev/kmsg
    DHCLIENT_PID=`cat $DHCLIENT_PID_FILE`
    kill $DHCLIENT_PID
}

stop_dhcpd()
{
    echo "stop_dhcpd" > /dev/kmsg
    DHCPD_PID=`cat $DHCPD_PID_FILE`
    kill $DHCPD_PID
    del_route_to_prefix
}

del_route_to_prefix()
{
    echo "$SCRIPT_NAME: Enter del_route_to_prefix" > /dev/kmsg
    IPV6_DHCP_PD=`cat $DHCPV6_PD_FILE`
    if [ -n $IPV6_DHCP_PD ] 
    then
        echo "$SCRIPT_NAME: Deleting route for $IPV6_DHCP_PD dev $LAN_IF" > /dev/kmsg
        /sbin/ip -6 route del $IPV6_DHCP_PD dev $LAN_IF
    fi
}

if [ $# -ne 3 ]; 
    then echo "illegal number of parameters"
    exit 1
fi

case "$1" in
    connect)
        get_ipv6_addr_from_interface
        move_ipv6_address_form_lte_to_lan

        #When DHCP-PD is used we need to run dhclient
        PD_MODE=`uci get lte-gw.ipv6_config.dhcp6_pd`
        if [ $PD_MODE != "disable" ]
        then
            #The dhcpd (server) is running from the dhclient-exit-hooks script if PD_MODE is
            #client-server
            start_dhclient
        fi
#       configure_ipv6_parm_for_lan
        ;;
    disconnect)
        remove_ipv6_from_lan
        
        PD_MODE=`uci get lte-gw.ipv6_config.dhcp6_pd`
        if [ $PD_MODE != "disable" ]
        then
            stop_dhclient

            #The dhcpd (server) is running from the dhclient-exit-hooks script
            PD_SRV_MODE=`uci get lte-gw.lan_ipv6_param.dhcp6_pd_server`
            if [ $PD_SRV_MODE = "enable" ]
            then
                stop_dhcpd
            fi
        fi
        ;;
        *)
        echo -e "\nUnknown arg $1\n\nUsage:\n `basename $0` connect | disconnect, lte interface, lan interface\n"
        exit 1
        ;;
esac

exit 0



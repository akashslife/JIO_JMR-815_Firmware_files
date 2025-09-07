#!/bin/sh


#Script get an interface name , route metric and a list of dns servers ipv4 ipv6
#it adds the dns server to resolv.conf (if not exist) and add a route rule to the dns server from the 
#interface supplayed


IF_NAME=$2
PDN_TYPE=$3
SCRIPT_NAME=`basename $0`
DNS_SRV_FILE="/etc/resolv.conf"
DNS_EXT_PDN_SRV_FILE="/etc/resolv.dnsmasq.conf"
DEFAULT_ROUTE_METRIC=100
EXT_ROUTE_METRIC=10
MODE=`uci get lte-gw.local_param.local_topoloy`
DNS_STATIC=`uci get lte-gw.static_dns.sdns_enable`
PRIMARY_STATIC_DNS=`uci get lte-gw.static_dns.sdns_primary_ip`
SECONDARY_STATIC_DNS=`uci get lte-gw.static_dns.sdns_secondary_ip`


nameserver_add()
{
    DNS_ADDR=$1

    
    echo "$SCRIPT_NAME updating dns $DNS_ADDR in $DNS_SRV_FILE" > /dev/kmsg
    grep -q "$DNS_ADDR" $DNS_SRV_FILE 2>/dev/null || echo nameserver $DNS_ADDR >> $DNS_SRV_FILE

    #For external PDN in router mode we modify dnsmasq resolve file
    #For the rest (Internal PDN) or external bridge we will modify Linux default resolve.conf
    if [ "$2" == "ext" -a $MODE == "router" ]; then
        echo "$SCRIPT_NAME updating dns $DNS_ADDR in $DNS_EXT_PDN_SRV_FILE" > /dev/kmsg
        grep -q "$DNS_ADDR" $DNS_EXT_PDN_SRV_FILE 2>/dev/null || echo nameserver $DNS_ADDR >> $DNS_EXT_PDN_SRV_FILE
    fi

    #jclee, 140304, added dns information

	IPV4_DNS_COUNT=0
	IPV6_DNS_COUNT=0

	while read DNS_INFO; do
	    if [ `echo $DNS_INFO | grep nameserver | grep "\." | wc -l ` -eq 1 ];then 
		# IPv4 DNS Information
		    if [ $IPV4_DNS_COUNT -eq 0 ];then
				ipv4_pri_dns=`echo $DNS_INFO | grep nameserver | grep "\." | awk '{print $2}'`
				uci set /tmp/wan.status.ipv4_pri_dns="$ipv4_pri_dns"
				IPV4_DNS_COUNT=$((IPV4_DNS_COUNT+1))
			elif [ $IPV4_DNS_COUNT -eq 1 ];then
				ipv4_sec_dns=`echo $DNS_INFO | grep nameserver | grep "\." | awk '{print $2}'`
				uci set /tmp/wan.status.ipv4_sec_dns="$ipv4_sec_dns"
			fi
		elif [ `echo $DNS_INFO | grep nameserver | grep "\:" | wc -l ` -eq 1 ];then 
		# IPv6 DNS Information
		    if [ $IPV6_DNS_COUNT -eq 0 ];then
				ipv6_pri_dns=`echo $DNS_INFO | grep nameserver | grep "\:" | awk '{print $2}'`
				uci set /tmp/wan.status.ipv6_pri_dns="$ipv6_pri_dns"
				IPV6_DNS_COUNT=$((IPV6_DNS_COUNT+1))
			elif [ $IPV6_DNS_COUNT -eq 1 ];then
				ipv6_sec_dns=`echo $DNS_INFO | grep nameserver | grep "\:" | awk '{print $2}'`
				uci set /tmp/wan.status.ipv6_sec_dns="$ipv6_sec_dns"
			fi
		fi
	done < $DNS_EXT_PDN_SRV_FILE

    uci commit /tmp/wan
}

route_to_dns()
{
    local metric=$DEFAULT_ROUTE_METRIC

    if [ "$3" == "ext" ]; then
        if [ $MODE == "router" ]; then
            metric=$EXT_ROUTE_METRIC
        else 
            #For External PDN in Bridge mode we dont add route rules
            return
        fi
    fi

    echo "$SCRIPT_NAME updating route to dns $1 via dev $2 with metric $metric" > /dev/kmsg
    case "$1" in 
    *:*)
        /sbin/ip -6 route add $1 dev $2 metric $metric > /dev/null 2>&1
    ;;
    *.*)
        /sbin/ip -4 route add $1 dev $2 metric $metric > /dev/null 2>&1
    ;;
    *)
        echo "$SCRIPT_NAME error: route_to_dns - $1 doesn't appears to be ipv4 or ipv6 valid address" > /dev/kmsg
    ;;
    esac

}

nameserver_print()
{
    cat $DNS_SRV_FILE
    cat $DNS_EXT_PDN_SRV_FILE
    if [ $DNS_MODE == "enable"] ; then
	    echo "static_dns=$DNS_MODE primary IP:$PRIMARY_STATIC_DNS, secondary ip:$SECONDARY_STATIC_DNS /n"
    fi

}

route_print()
{
    echo "$SCRIPT_NAME : route_print"
}

remove_route_to_dns()
{
    echo "$SCRIPT_NAME : remove_route_to_dns"
}

nameserver_del()
{
    if [ "$1" == "ext" ]; then
        if [ $MODE == "router" ]; then
            echo "$SCRIPT_NAME : Flushing $DNS_EXT_PDN_SRV_FILE" > /dev/kmsg
            echo -n > $DNS_EXT_PDN_SRV_FILE 2>/dev/null
        fi
    fi

    #jclee, 140304, added dns information
    uci set /tmp/wan.status.ipv4_pri_dns=''
    uci set /tmp/wan.status.ipv4_sec_dns=''
    uci set /tmp/wan.status.ipv6_pri_dns=''
    uci set /tmp/wan.status.ipv6_sec_dns=''
    uci commit /tmp/wan
}

print_usage()
{
    echo -e "\nUnknown arg $1\n\nUsage:\n $SCRIPT_NAME (add | del | status) interface pdn_type dns-server-list(ipv4/ipv6)\n"
}

add_dns_resolve_options()                     
{                                                         
    if [ ! -f $DNS_SRV_FILE ] ; then 
		echo "options attempts:1" > $DNS_SRV_FILE
        echo "options timeout:3" >> $DNS_SRV_FILE
    fi
    
    if [ "$PDN_TYPE" == "ext" -a $MODE == "router" ] ; then
    	
    	if [ ! -f $DNS_EXT_PDN_SRV_FILE ] ; then 
    		echo "options attempts:1" > $DNS_EXT_PDN_SRV_FILE
            echo "options timeout:3" >> $DNS_EXT_PDN_SRV_FILE
    	fi
    fi
} 

add_dns_and_route()
{
    add_dns_resolve_options
    
    if [ $DNS_STATIC == "enable" ] && [ "$PDN_TYPE" == "ext" ]; then
	nameserver_add $PRIMARY_STATIC_DNS "ext"
        route_to_dns $PRIMARY_STATIC_DNS $IF_NAME "ext"
        nameserver_add $SECONDARY_STATIC_DNS "ext"
        route_to_dns $SECONDARY_STATIC_DNS $IF_NAME "ext"
    fi
    for i in $1 $2 $3 $4 $5 $6
    do
        nameserver_add $i $PDN_TYPE
        route_to_dns $i $IF_NAME $PDN_TYPE
    done
   
    if [ "$PDN_TYPE" == "ext" -a $MODE == "router" ]; then
        /usr/local/bin/dhcp-ctrl.sh refresh &
    fi
}

del_dns()
{
    nameserver_del $PDN_TYPE
    if [ "$PDN_TYPE" == "ext" -a $MODE == "router" ]; then
        /usr/local/bin/dhcp-ctrl.sh refresh
    fi
}

case "$1" in
    add)
        #Start from the 3rd element
        add_dns_and_route $4 $5 $6 $7 $8 $9
        ;;
    del)
        del_dns &
        ;;
    status)
        nameserver_print
        route_print
        ;;
        *)
        print_usage
        ;;
esac


#no error reporting
return 0

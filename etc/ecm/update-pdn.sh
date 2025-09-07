#!/bin/sh
#
# update a specific PDN in the system
#

ACTION=$1
IFNAME=$2
ADDRFAMILY=$3
IPADDR=$4
IPADDR_HOST=$5
DEFAULT_ROUTE_METRIC=10

get_address_family() {
    if [ `echo $1 | tr -s '[:upper:]' '[:lower:]'` = "ipv6" ]
    then
        echo "-6" ## IPv6 format
    else
        echo "-4"   ## IPv4 format
    fi
}

is_ipaddr_routed() {
    local SEARCH_PATTERN="$1( via [0-9.]+)? dev $IFNAME"
    local FAMILY=$2
    local RESULT=`ip $FAMILY ro | grep -E "${SEARCH_PATTERN}"`

    if [ `echo ${#RESULT}` -gt 0 ]
    then
            echo "1"
    else
            echo "0"
    fi
}

add_ipaddr_to_routing_table() {
    local FAMILY=$(get_address_family $1)
    local OPTS=""

    if [ $(is_ipaddr_routed $IPADDR $FAMILY) = 0 ]
    then
        if [ ! -z "$IPADDR_HOST" ]
        then
            OPTS="via $IPADDR_HOST"
        fi

        ip $FAMILY route add $IPADDR $OPTS dev $IFNAME metric $DEFAULT_ROUTE_METRIC
    fi
}


del_ipaddr_from_routing_table() {
    local FAMILY=$(get_address_family $1)

    if [ $(is_ipaddr_routed $IPADDR $FAMILY) = 1 ]
    then
        # delete IP address from the route table
        ip $FAMILY route del $IPADDR dev $IFNAME
    fi
}

case $ACTION in
    'add-ip')
        add_ipaddr_to_routing_table $ADDRFAMILY $IPADDR 
    ;;
    'del-ip')
        del_ipaddr_from_routing_table $ADDRFAMILY $IPADDR
    ;;
esac

return 0

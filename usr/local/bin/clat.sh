#!/bin/sh

EXE="/usr/local/bin/clat.sh"
TAYGA_CONFF="/etc/tayga.conf"
TUN_DRV="/lib/modules/3.4.22/kernel/drivers/net/tun.ko"
CLAT_DEV="nat64"

config_tayga_conf() {
    DHCP_FROM=`uci get /etc/config/lte-gw.dhcp_srv.range_from_ip`
    DHCP_TO=`uci get /etc/config/lte-gw.dhcp_srv.range_to_ip`

    IP_P1=`echo $DHCP_FROM | cut -d . -f 1`
    IP_P2=`echo $DHCP_FROM | cut -d . -f 2`
    IP_P3=`echo $DHCP_FROM | cut -d . -f 3`
    IP_S=`echo $DHCP_FROM | cut -d . -f 4`
    IP_E=`echo $DHCP_TO | cut -d . -f 4`
    echo $IPS $IPE
    
    V4_ADDR="192.0.0.4"
    V6_ADDR=$2
    V6_INTERM=`echo ${V6_ADDR%:*}`
    V6_PREFIX=`echo ${V6_INTERM%:*}`
    echo $V6_PREFIX

    printf "data-dir /tmp/tayga\n" >> $TAYGA_CONFF
    #add a internal map
    printf "map %s %s::c1a7\n" $V4_ADDR $V6_PREFIX >> $TAYGA_CONFF
    let cnt=$IP_S
    while [  $cnt -le $IP_E  ]; do
        printf "map %d.%d.%d.%d " $IP_P1 $IP_P2 $IP_P3 $cnt >> $TAYGA_CONFF
        printf "%s:%.2x%.2x:%.2x%.2x" $V6_PREFIX $IP_P1 $IP_P2 $IP_P3 $cnt >> $TAYGA_CONFF
        printf "\n" >> $TAYGA_CONFF
        let cnt=cnt+1
    done
}

config_add_routes() {
    V6_ADDR=$1
    V6_INTERM=`echo ${V6_ADDR%:*}`
    V6_PREFIX=`echo ${V6_INTERM%:*}`
    echo $V6_PREFIX
    
    ip route add $V6_PREFIX::/96 dev $CLAT_DEV
    printf "%s::/96 dev %s " $V6_PREFIX $CLAT_DEV > /tmp/clat_route_entry
    
    ip -4 route add default dev $CLAT_DEV
}

config_del_routes() {
    ROUTE_ENTRY=`cat /tmp/clat_route_entry |grep $CLAT_DEV`
    
    ip route del $ROUTE_ENTRY
    
    ip -4 route del default dev $CLAT_DEV
}

CLAT_MODE=`uci get lte-gw.nat.clat_mode 2> /dev/null`
if [ $? -ne 0 ];
then
    echo "did not find clat option in uci" > /dev/kmsg
    exit 0
fi
        
if [ $CLAT_MODE == "disable" ];
then
    echo "Clat disabled" > /dev/kmsg
    exit 0
fi

INTERNET_INTERACE_FILE='/tmp/internet_if.txt'
#Check the the file exist.
if [ ! -e $INTERNET_INTERACE_FILE ]
then
    EXTIF="lte0.1"
else
    #The internet LTE interface lte0 / lte0.1 etc...
    EXTIF=`cat $INTERNET_INTERACE_FILE` 
fi

case "$1" in
  start)
        echo "Clat start" > /dev/kmsg

        IPV4_LTE_ADDRESS="`LC_ALL=C ip -4 addr show $EXTIF | awk '/inet/ { print $2 }' | cut -d "/" -f 1`"
        IPV6_LTE_ADDRESS=`/sbin/ip addr show $EXTIF | grep -i global | awk '/inet6/ {print $2}' | cut -f1 -d'/'`
        
        if [ -n "$IPV4_LTE_ADDRESS" ]; then
            echo "$SCRIPT_NAME Exit: Found IPv4 adderss $IPV4_LTE_ADDRESS on $EXTIF" > /dev/kmsg
            exit 0
        fi
		
        if [ -z "$IPV6_LTE_ADDRESS" ]; then
            echo "$SCRIPT_NAME Exit: NOT Found Global IPv6 adderss on $EXTIF" > /dev/kmsg
            exit 0
        fi

        rm -rf $TAYGA_CONFF
        modprobe tun  
		
        clatd -i $CLAT_DEV
        ;;
		
  set)
        echo "Clat set" > /dev/kmsg
        echo 0 > /proc/sys/net/ipv6/conf/nat64/disable_ipv6
        ip link set up dev $CLAT_DEV
        ip -4 address add $2 dev $CLAT_DEV
        #ip -6 route add $3 dev $CLAT_DEV
        config_tayga_conf $2 $3
        config_add_routes $3
		
        tayga --config $TAYGA_CONFF &
        ;;
		
  stop)
        echo "Clat stop" > /dev/kmsg
		
        killall clatd  > /dev/null 2>&1
        #Cleanup: Removing CLAT device
        tayga --config $TAYGA_CONFF --rmtun
        #Cleanup: Deleting TAYGA config file:
        killall tayga
        rm -rf $TAYGA_CONFF
        #ifconfig $CLAT_DEV down
        #rmmod tun
        config_del_routes

        ;;
		
  restart|reload|force-reload)
        `$EXE stop`
        `$EXE start`
        ;;
        
  new-ip)
        #First check if clat is already running.
        #if not exit
        echo "Clatd new LTE IP" > /dev/kmsg
    
        kill -0 `cat /var/run/clatd.pid 2>/dev/null` > /dev/null 2>&1
        if [ $? != '0' ]
        then
            echo "Clatd not started yet" > /dev/kmsg
            exit 0;
        else
        #If clat is already running, we need to re-add iptables chain and rules and restart it on the new interface
        #No need to remove iptables rule as they where deleted from nat-conf.sh
        echo "Clat stop" > /dev/kmsg
        killall clatd  > /dev/null 2>&1
        tayga --config $TAYGA_CONFF -rmtun
	killall tayga
        `$EXE start`    
        fi
        ;;
        
  *)
        echo "Wrong parameter"
        exit 2
        ;;
esac
exit 0

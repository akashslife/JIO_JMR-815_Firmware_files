#!/bin/sh

#Export the relevent interfaces name
. /usr/local/bin/lte-gw-global-env.sh

#DHCP Options configuration files
DNSMASQ_CONF_FILE="/etc/dnsmasq.conf"

MODE=`uci get lte-gw.local_param.local_topoloy`

config_dhcp_file() {


    DNSMASQ_PID=`pidof dnsmasq 2>/dev/null`

    LOCAL_IP=`uci get lte-gw.local_param.local_ip_addr`
    LOCAL_MASK=`uci get lte-gw.local_param.local_ip_mask`
    HOST_NAME=`uci get system.system.hostname`

    DHCP_SRV_RANGE_FROM=`uci get lte-gw.dhcp_srv.range_from_ip`
    DHCP_SRV_RANGE_TO=`uci get lte-gw.dhcp_srv.range_to_ip`

    #Set the listen address
    sed -i -e "s/^listen-address=.*$/listen-address=$LOCAL_IP/g" $DNSMASQ_CONF_FILE

    if [ $MODE = "router" ]; then  

        local DHCP_SRV_ENABLE=`uci get lte-gw.dhcp_srv.dhcp_enable`
        local DHCP_SRV_LEASE_TIME="`uci get lte-gw.dhcp_srv.lease_time_min`m"

        local DHCP_HOSTS_LEASE_TMP_FILE="/tmp/dnsmasq.leases"

        #set LAN Side interface (usb / eth)
        if [ $PROJECT_TYPE == "WRT" ] || [ $PROJECT_TYPE == "PWRT" ]
        then
        	sed -i -e "s/^interface=.*$/interface=$BRIDGE_IF/g" $DNSMASQ_CONF_FILE
        else
        	sed -i -e "s/^interface=.*$/interface=$LAN_IF/g" $DNSMASQ_CONF_FILE
        fi

        #update the host address range in dnsmasq.conf:
        sed -i -e "s/^dhcp-range=[^:]*$/dhcp-range=$DHCP_SRV_RANGE_FROM,$DHCP_SRV_RANGE_TO,$DHCP_SRV_LEASE_TIME/g" $DNSMASQ_CONF_FILE
        sed -i -e "s/^dhcp-option=1.*$/dhcp-option=1,$LOCAL_MASK/g" $DNSMASQ_CONF_FILE

        add_static_dhcp

        if [ $DHCP_SRV_ENABLE == "enable" ]
        then
            local TEMP_FILE="/tmp/dnsmasq.tmp"
            cat $DNSMASQ_CONF_FILE | grep -v "no-dhcp-interface" > $TEMP_FILE 
            mv $TEMP_FILE $DNSMASQ_CONF_FILE > /dev/null 2>&1
        else
            echo "no-dhcp-interface=$LAN_IF" >> $DNSMASQ_CONF_FILE
        fi

    # MODE = bridge
    else
        #update the host address IP in dnsmasq.conf:
        sed -i -e "s/^dhcp-range=[^:]*$/dhcp-range=$DHCP_SRV_RANGE_FROM,$DHCP_SRV_RANGE_FROM,168h/g" $DNSMASQ_CONF_FILE
        sed -i -e "s/^interface=.*$/interface=$BRIDGE_IF/g" $DNSMASQ_CONF_FILE
    fi


    #restart only if dnsmasq is up.(during init phase the daemon might be
    #lodaing after this script is called)
    if [ -n "$DNSMASQ_PID" ] ; then
        `/usr/local/bin/dhcp-ctrl.sh stop > /dev/null 2>&1`
    fi

    #set the local ip for the dnsmasq listen
    sed -i -e "s/^listen-address=.*$/listen-address=$LOCAL_IP/g" $DNSMASQ_CONF_FILE

    #Add DNS Alias Names for the device
    sed -i -e "s/^address=.*$/address=\/$HOST_NAME\/$LOCAL_IP/g" $DNSMASQ_CONF_FILE
}

#Add static hosts to the file
add_static_dhcp() {
    
    if [ $MODE = "router" ]; then
        #The file where we holds to static host mapping MAC-> IP
        local DHCP_HOSTS_FILE="/tmp/dhcp-hosts.conf"
        #first clear the option and the host file
        echo -n "" > $DHCP_HOSTS_FILE 
        local DHCP_SRV_STATIC_HOSTS_NUM=`uci get lte-gw.dhcp_srv.host_reservation_num`
        local COUNTER=0

        while [  $COUNTER -lt  $DHCP_SRV_STATIC_HOSTS_NUM ]; do

            local RULE_ENABLE=`uci get lte-gw-dhcp-hosts.@dhcp_static_host[$COUNTER].enable`
            if [ $RULE_ENABLE == "enable" ]
            then
                tmp_MAC=`uci get lte-gw-dhcp-hosts.@dhcp_static_host[$COUNTER].mac_addr`
                MAC=`echo $tmp_MAC | tr '[A-Z]' '[a-z]'`
                IP=`uci get lte-gw-dhcp-hosts.@dhcp_static_host[$COUNTER].ip_addr`
                LEASE=`uci get lte-gw-dhcp-hosts.@dhcp_static_host[$COUNTER].lease_time_min`
                echo  "$MAC,$IP,$LEASE" >> $DHCP_HOSTS_FILE
            fi

            let COUNTER=COUNTER+1 
        done
    fi
}

config_mng_host_address() {
    if [ $DEBUG_IF = "usb0" ]; then
        local MNG_DNSMASQ_CONF="/etc/dnsmasq-mng.conf"
        local USB_IP_ADDRESS=`uci get lte-gw.usb_param.ip_addr`
        local USB_NETMASK=`uci get lte-gw.usb_param.netmask`
        local USB_HOST_IP_ADDRESS=`uci get lte-gw.usb_param.ip_host`
#        local USB_HOST_MAC_ADDRESS=`uci get lte.config.host_addr` #ntmore added,jclee,fixed for usb incorrect mac when updated firmware until reconnect the usb"
	local USB_HOST_MAC_ADDRESS=`uci get /nvm/etc/static-config/Identification.Device.Usb0HostMacAdd`

        sed -i -e "s/^listen-address=.*$/listen-address=$USB_IP_ADDRESS/g" $MNG_DNSMASQ_CONF
        sed -i -e "s/^dhcp-range=.*$/dhcp-range=$USB_HOST_IP_ADDRESS,$USB_HOST_IP_ADDRESS,168h/g" $MNG_DNSMASQ_CONF
        sed -i -e "s/^dhcp-host=.*$/dhcp-host=$USB_HOST_MAC_ADDRESS,$USB_HOST_IP_ADDRESS,168h/g" $MNG_DNSMASQ_CONF
    fi
}

case "$1" in
    init)

	#ntmore added, check for broken dnsmsaq
	if [ ! -f /etc/dnsmasq.conf ] || [ `cat /etc/dnsmasq.conf |wc -L` == "0" ];then
		cp /configuration_defaults/PWRT/nvm/etc/dns_configs/dnsmasq.conf /etc/
	fi

        config_dhcp_file
        add_static_dhcp
        ;;

    *)
        config_dhcp_file
        config_mng_host_address
        ;;
esac

# trigger database update of UCI parameters
DBP_EN=`uci get service.DBPROBE.Enabled`
if [ $DBP_EN = 'true' ]
then                     
    db_writer -p probe2_update_trigger 1      
fi


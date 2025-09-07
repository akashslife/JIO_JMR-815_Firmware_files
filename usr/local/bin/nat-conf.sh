#!/bin/sh

#Export the relevent interfaces name
. /usr/local/bin/lte-gw-global-env.sh

IPTABLES_CONFIG_FILE="/tmp/iptables"
IPTABLES_RESTORE_EXE="iptables-restore"
INTERNET_INTERACE_FILE='/tmp/internet_if.txt'
IP_FILE='/tmp/PdnIp.txt'

NAT_DMZ_ENABLE=`uci get lte-gw.nat.dmz_enable`
NAT_DMZ_IP=`uci get lte-gw.nat.dmz_host_ip`
NAT_NUM_OF_PORT_FWD=`uci get lte-gw.nat.port_fwd_num`

PORT_FILTER_ENABLE=`uci get lte-gw.port_filter.filter_enable`
PORT_FILTER_NUM=`uci get lte-gw.port_filter.port_filter_num`


COUNTER=0



# trigger database update of UCI parameters
DBP_EN=`uci get service.DBPROBE.Enabled`
if [ $DBP_EN = 'true' ]
then                     
    db_writer -p probe2_update_trigger 1      
fi

#Check the the file exist.
if [ ! -e $INTERNET_INTERACE_FILE ]
then
    exit
fi

#The internaet LTE interface lte0 / lte0.1 etc...
LTE_INTERFACE=`cat $INTERNET_INTERACE_FILE`
LTE_IP=`cat $IP_FILE`

#if there is no lte interface , we cannot continuo.
if [ -z $LTE_INTERFACE ]
then
    exit
fi

#clear iptables file
echo -n "" > $IPTABLES_CONFIG_FILE

#Preper the NAT table
cat >> $IPTABLES_CONFIG_FILE << EOF
*nat
:PREROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
EOF

while [  $COUNTER -lt  $NAT_NUM_OF_PORT_FWD ]; do

    RULE_ENABLE=`uci get lte-gw-port-fwd.@port_fwd[$COUNTER].enable`

    if [ $RULE_ENABLE == "enable" ]
    then
        SRC_IP=`uci get lte-gw-port-fwd.@port_fwd[$COUNTER].src_ip_addr`
        PROTO=`uci get lte-gw-port-fwd.@port_fwd[$COUNTER].protocol`
        EXT_PORT_FROM=`uci get lte-gw-port-fwd.@port_fwd[$COUNTER].ext_port_from`
        EXT_PORT_TO=`uci get lte-gw-port-fwd.@port_fwd[$COUNTER].ext_port_to`
        DST_IP=`uci get lte-gw-port-fwd.@port_fwd[$COUNTER].dst_ip_addr`
        DST_PORT=`uci get lte-gw-port-fwd.@port_fwd[$COUNTER].dst_port`

        if [ $SRC_IP == "all" ] 
        then
            #For all sourch IPs 0/0
            SRC_MATCH="-s 0/0"
        else
            SRC_MATCH="-s $SRC_IP"
        fi

        if [ $EXT_PORT_FROM == $EXT_PORT_TO ] 
        then
            PORT_MATCH="--dport $EXT_PORT_FROM"
            DEST="--to-destination $DST_IP:$DST_PORT"
        else
            #if given a range of external ports, keep the port range
            #Send it to a spesifc Local IP.
            PORT_MATCH="--dport $EXT_PORT_FROM:$EXT_PORT_TO"
            DEST="--to-destination $DST_IP"
        fi

        if [ $PROTO == "both" ]
        then
            echo "-A PREROUTING -i $LTE_INTERFACE $SRC_MATCH -p tcp -m tcp $PORT_MATCH -j DNAT $DEST" >> $IPTABLES_CONFIG_FILE
            echo "-A PREROUTING -i $LTE_INTERFACE $SRC_MATCH -p udp -m udp $PORT_MATCH -j DNAT $DEST" >> $IPTABLES_CONFIG_FILE
        else
            echo "-A PREROUTING -i $LTE_INTERFACE $SRC_MATCH -p $PROTO -m $PROTO $PORT_MATCH -j DNAT $DEST" >> $IPTABLES_CONFIG_FILE
        fi
    fi

    let COUNTER=COUNTER+1 
done

if [ $NAT_DMZ_ENABLE == "enable" ] 
then
    if [ $NAT_DMZ_IP != "0.0.0.0" ] 
    then
        echo "-A PREROUTING -i $LTE_INTERFACE -j DNAT --to-destination $NAT_DMZ_IP" >> $IPTABLES_CONFIG_FILE
    fi
fi
#NTmore added
/usr/local/bin/firewall-init.sh nat

#NAT MASQUERADE rule,MANGLE table and the FILTER table
cat >> $IPTABLES_CONFIG_FILE << EOF
-A POSTROUTING -o $LTE_INTERFACE -j SNAT --to-source $LTE_IP
COMMIT
*mangle
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
COMMIT
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
EOF
# PORT FILTERING
if [ $PORT_FILTER_ENABLE == "enable" ] 
then
	COUNTER=0
	while [  $COUNTER -lt  $PORT_FILTER_NUM ]; do

    		RULE_ENABLE=`uci get lte-gw-port-filter.@filter_entry[$COUNTER].enable`

    		if [ $RULE_ENABLE == "enable" ]
	    	then
		        SRC_IP=`uci get lte-gw-port-filter.@filter_entry[$COUNTER].src_ip_addr`
		        PROTO=`uci get lte-gw-port-filter.@filter_entry[$COUNTER].protocol`
		        EXT_PORT_FROM=`uci get lte-gw-port-filter.@filter_entry[$COUNTER].ext_port_from`
		        EXT_PORT_TO=`uci get lte-gw-port-filter.@filter_entry[$COUNTER].ext_port_to`
		

		        if [ $SRC_IP == "all" ] 
        		then
		            #For all sourch IPs 0/0
		            SRC_MATCH="-s 0/0"
		        else
		            SRC_MATCH="-s $SRC_IP"
		        fi

		        if [ $EXT_PORT_FROM == $EXT_PORT_TO ] 
		        then
		            PORT_MATCH="--dport $EXT_PORT_FROM"
		        else
		            #if given a range of external ports, keep the port range
		            #Send it to a spesifc Local IP.
		            PORT_MATCH="--dport $EXT_PORT_FROM:$EXT_PORT_TO"
		        fi

		        if [ $PROTO == "both" ]
		        then
			    # no need for source interface -i $LTE_INTERFACE 
		            echo "-A FORWARD  $SRC_MATCH -p tcp -m tcp $PORT_MATCH -j DROP" >> $IPTABLES_CONFIG_FILE
		            echo "-A FORWARD  $SRC_MATCH -p udp -m udp $PORT_MATCH -j DROP" >> $IPTABLES_CONFIG_FILE
		        else
		            echo "-A FORWARD  $SRC_MATCH -p $PROTO -m $PROTO $PORT_MATCH -j DROP" >> $IPTABLES_CONFIG_FILE
		        fi
		fi

    		let COUNTER=COUNTER+1 
	done
fi


#NTmore added
/usr/local/bin/firewall-init.sh filter

cat >> $IPTABLES_CONFIG_FILE << EOF
COMMIT
EOF

#Restore the created file to the iptables
#This flash all previous rules before
$IPTABLES_RESTORE_EXE < $IPTABLES_CONFIG_FILE

#NTmore added
#/usr/local/bin/firewall-control.sh init

UPNP_MODE=`uci get lte-gw.nat.upnp_mode`

if [ $UPNP_MODE == "enable" ] 
then
    /usr/local/bin/upnp.sh new-ip
fi





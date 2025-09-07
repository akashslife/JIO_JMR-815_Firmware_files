#!/bin/sh

if [ -e /proc/device-tree/wlan_type ]; then
	WLAN_TYPE=$(cat /proc/device-tree/wlan_type);
else
	WLAN_TYPE="ATH"
fi

if [ $WLAN_TYPE == "RTL" ] || [ $WLAN_TYPE == "RTL8189" ]; then
    echo "RTL Board - init script will configure RTL parameters"
    /root/script/init.sh
    exit 0
else
    echo "ATH board"
fi

#backup the conf file
local OPEN_CONF_FILE_SAMPLE="/etc/config/ath6k_conf/hapd_open.conf.sample"
local OPEN_CONF_FILE="/etc/config/ath6k_conf/hapd_open.conf"
local OPEN_SECOND_CONF_FILE="/etc/config/ath6k_conf/hapd_second_open.conf"
local COUNTER=0
local ACCEPT_MAC_FILE="/etc/config/ath6k_conf/hostapd.accept"    
local DENY_MAC_FILE="/etc/config/ath6k_conf/hostapd.deny"
local ACCEPT_SECOND_MAC_FILE="/etc/config/ath6k_conf/hostapd_second.accept"
local DENY_SECOND_MAC_FILE="/etc/config/ath6k_conf/hostapd_second.deny"
local ACCEPT_FILE="/etc/config/wifi-accept"
local DENY_FILE="/etc/config/wifi-deny"
local ACCEPT_SECOND_FILE="/etc/config/wifi-second-accept"
local DENY_SECOND_FILE="/etc/config/wifi-second-deny"

cp -f $OPEN_CONF_FILE_SAMPLE $OPEN_CONF_FILE

SECOND_SSID_ENABLED=`uci get /etc/config/wifi-second.wifi_start.second_ssid_enabled`

if [ $SECOND_SSID_ENABLED = "enable" ]; then
    echo "second ssid is enabled"
    cp -f $OPEN_CONF_FILE_SAMPLE $OPEN_SECOND_CONF_FILE
    iw wlan0 interface add wlan1 type __ap
    sed -i -e "s/^interface=.*$/interface=wlan1/g" $OPEN_SECOND_CONF_FILE
fi

let SSID_NO=0
let EXIT_LOOP=0
CONF_FILE_NAME='wifi'
HAPD_CONF_FILE=$OPEN_CONF_FILE
HAPD_ACCEPT_FILE=$ACCEPT_MAC_FILE
HAPD_DENY_FILE=$DENY_MAC_FILE
ACCEPT_FILE_SRC=$ACCEPT_FILE
DENY_FILE_SRC=$DENY_FILE

while [ $EXIT_LOOP = 0 ]; do
    if [ $SSID_NO = 0 ]; then
	HAPD_CONF_FILE=$OPEN_CONF_FILE
        CONF_FILE_NAME='wifi'
	HAPD_ACCEPT_FILE=$ACCEPT_MAC_FILE
	HAPD_DENY_FILE=$DENY_MAC_FILE
	ACCEPT_FILE_SRC=$ACCEPT_FILE
	DENY_FILE_SRC=$DENY_FILE
	echo "handling ssid $SSID_NO file: $HAPD_CONF_FILE conf name: $CONF_FILE_NAME"
    else
	HAPD_CONF_FILE=$OPEN_SECOND_CONF_FILE
        CONF_FILE_NAME='wifi-second'
	HAPD_ACCEPT_FILE=$ACCEPT_SECOND_MAC_FILE
	HAPD_DENY_FILE=$DENY_SECOND_MAC_FILE
	ACCEPT_FILE_SRC=$ACCEPT_SECOND_FILE
	DENY_FILE_SRC=$DENY_SECOND_FILE
	echo "handling ssid $SSID_NO file: $HAPD_CONF_FILE conf name: $CONF_FILE_NAME"
    fi

    SSID=`uci get /etc/config/$CONF_FILE_NAME.wifi.ssid`
    TECHNOLOGY=`uci get /etc/config/$CONF_FILE_NAME.wifi.technology`
    ENCRIPTION=`uci get /etc/config/$CONF_FILE_NAME.wifi.sec_encryption`
    PAIRWISE=`uci get /etc/config/$CONF_FILE_NAME.wifi.sec_pairwise`
    PASSWORD=`uci get /etc/config/$CONF_FILE_NAME.wifi.sec_pass`
    IGNORE_BROADCAST_SSID=`uci get /etc/config/$CONF_FILE_NAME.wifi.ignore_broadcast_ssid`
    MACADDR_ACL_POLICY=`uci get /etc/config/$CONF_FILE_NAME.wifi.macaddr_acl`
    MAC_ADDR_ACCEPT_NUM=`uci get /etc/config/$CONF_FILE_NAME.wifi.accept_mac_num`
    MAC_ADDR_DENY_NUM=`uci get /etc/config/$CONF_FILE_NAME.wifi.deny_mac_num`
    WMM_ENABLED=`uci get /etc/config/$CONF_FILE_NAME.wifi.wmm_enabled`
    WEP_KEY0=`uci get /etc/config/$CONF_FILE_NAME.wifi.sec_wep_key0`
    WEP_KEY1=`uci get /etc/config/$CONF_FILE_NAME.wifi.sec_wep_key1`
    WEP_KEY2=`uci get /etc/config/$CONF_FILE_NAME.wifi.sec_wep_key2`
    WEP_KEY3=`uci get /etc/config/$CONF_FILE_NAME.wifi.sec_wep_key3`
    WEP_DEFAULT_KEY=`uci get /etc/config/$CONF_FILE_NAME.wifi.sec_wep_default_key`
    CHANNEL=`uci get /etc/config/$CONF_FILE_NAME.wifi.channel`
    CHANNEL_SELECT=`uci get /etc/config/$CONF_FILE_NAME.wifi.wifi_channel_select`
    TXPOWER=`uci get /etc/config/$CONF_FILE_NAME.wifi.tx_power`
    WPS_ENABLED=`uci get /etc/config/$CONF_FILE_NAME.wifi.wps_enabled`
    WPS_ROUTER_PIN=`uci get /etc/config/$CONF_FILE_NAME.wifi.wps_router_pin`
    WIFI_MCAST_RATE=`uci get /etc/config/$CONF_FILE_NAME.wifi.mcast_rate`
	
    sed -i -e "s/^ssid=.*$/ssid=$SSID/g" $HAPD_CONF_FILE
    sed -i -e "s/^channel=.*$/channel=$CHANNEL/g" $HAPD_CONF_FILE
    if [ $CHANNEL_SELECT = "manual" ];then
	    sed -i -e "s/^#channel=.*$/channel=$CHANNEL/g" $HAPD_CONF_FILE
	    sed -i -e "s/^acs=1*$/#acs=1/g" $HAPD_CONF_FILE
    else
	    sed -i -e "s/^channel=.*$/#channel=$CHANNEL/g" $HAPD_CONF_FILE
	    sed -i -e "s/^#acs=1*$/acs=1/g" $HAPD_CONF_FILE
    fi
    sed -i -e "s/^hw_mode=.*$/hw_mode=g/g" $HAPD_CONF_FILE
    sed -i -e "s/^ignore_broadcast_ssid=.*$/ignore_broadcast_ssid=$IGNORE_BROADCAST_SSID/g" $HAPD_CONF_FILE
    if [ $MACADDR_ACL_POLICY -ne "0" ]; then
	    sed -i -e "s/^#acl_policy=.*$/acl_policy=$MACADDR_ACL_POLICY/g" $HAPD_CONF_FILE
    fi

    sed -i -e "s/^tx_power=.*$/tx_power=$TXPOWER/g" $HAPD_CONF_FILE
                                                                                 
    #test ACL policy - 0- allow all , 1 - allow only what is in list , 2 - deny only what is in list
    if [ $MACADDR_ACL_POLICY = "1" ]; then
	if [ $SSID_NO == 0 ]; then
	    sed -i -e "s/^acl_mac_file=.*$/acl_mac_file=\/etc\/config\/ath6k_conf\/hostapd.accept/g" $HAPD_CONF_FILE
	else
	    sed -i -e "s/^acl_mac_file=.*$/acl_mac_file=\/etc\/config\/ath6k_conf\/hostapd_second.accept/g" $HAPD_CONF_FILE
	fi
    else
	if [ $MACADDR_ACL_POLICY = "2" ]; then
	    if [ $SSID_NO == 0 ]; then
                sed -i -e "s/^acl_mac_file=.*$/acl_mac_file=\/etc\/config\/ath6k_conf\/hostapd.deny/g" $HAPD_CONF_FILE
            else
                sed -i -e "s/^acl_mac_file=.*$/acl_mac_file=\/etc\/config\/ath6k_conf\/hostapd_second.deny/g" $HAPD_CONF_FILE
            fi
        fi
    fi
    
    if [ $WMM_ENABLED = "enable" ]; then
	sed -i -e "s/^wmm_enabled=.*$/wmm_enabled=1/g" $HAPD_CONF_FILE
    else
	sed -i -e "s/^wmm_enabled=.*$/wmm_enabled=0/g" $HAPD_CONF_FILE
    fi
    
    if [ $WPS_ENABLED = "enable" ]; then
	sed -i -e "s/^#wps_state=.*$/wps_state=2/g" $HAPD_CONF_FILE
	sed -i -e "s/^#eap_server=.*$/eap_server=1/g" $HAPD_CONF_FILE
	sed -i -e "s/^#ap_pin=.*$/ap_pin=$WPS_ROUTER_PIN/g" $HAPD_CONF_FILE
    fi
	    
    if [[ "$TECHNOLOGY" = "gn" || "$TECHNOLOGY" = "bgn" ]]; then
	sed -i -e "s/^ieee80211n=.*$/ieee80211n=1/g" $HAPD_CONF_FILE
    else
	sed -i -e "s/^ieee80211n=.*$/ieee80211n=0/g" $HAPD_CONF_FILE
    fi
    
    if [ $ENCRIPTION = "wep" ]; then
        sed -i -e "s/^#wep_default_key=0.*$/wep_default_key=$WEP_DEFAULT_KEY/g" $HAPD_CONF_FILE
	sed -i -e "s/^#wep_key0=12345678901234567890123456.*$/wep_key0=$WEP_KEY0/g" $HAPD_CONF_FILE
	sed -i -e "s/^#wep_key1=12345678901234567890123456.*$/wep_key1=$WEP_KEY1/g" $HAPD_CONF_FILE
	sed -i -e "s/^#wep_key2=12345678901234567890123456.*$/wep_key2=$WEP_KEY2/g" $HAPD_CONF_FILE
	sed -i -e "s/^#wep_key3=12345678901234567890123456.*$/wep_key3=$WEP_KEY3/g" $HAPD_CONF_FILE
    else
    if [ $ENCRIPTION = "wpa" ]; then
	sed -i -e "s/^#wpa=1.*$/wpa=1/g" $HAPD_CONF_FILE
	sed -i -e "s/^#wpa_passphrase=.*$/wpa_passphrase=$PASSWORD/g" $HAPD_CONF_FILE
	sed -i -e "s/^#wpa_pairwise=TKIP.*$/wpa_pairwise=$PAIRWISE/g" $HAPD_CONF_FILE
    else
    if [ $ENCRIPTION = "wpa2" ]; then 
	sed -i -e "s/^#wpa=2.*$/wpa=2/g" $HAPD_CONF_FILE
	sed -i -e "s/^#wpa_passphrase=.*$/wpa_passphrase=$PASSWORD/g" $HAPD_CONF_FILE
	sed -i -e "s/^#rsn_pairwise=CCMP.*$/rsn_pairwise=$PAIRWISE/g" $HAPD_CONF_FILE
    else
    if [ $ENCRIPTION = "mixed-wpa-wpa2" ]; then 
	sed -i -e "s/^#wpa=1.*$/wpa=3/g" $HAPD_CONF_FILE
	sed -i -e "s/^#wpa_passphrase=.*$/wpa_passphrase=$PASSWORD/g" $HAPD_CONF_FILE
	sed -i -e "s/^#wpa_pairwise=TKIP.*$/wpa_pairwise=$PAIRWISE/g" $HAPD_CONF_FILE
    fi
    fi
    fi
	fi
	
    #Add ACCEPT mac addr to file
    rm -f $HAPD_ACCEPT_FILE
    touch $HAPD_ACCEPT_FILE
    let COUNTER=0
    while [  $COUNTER -lt  $MAC_ADDR_ACCEPT_NUM ]; do
	MAC=`uci get $ACCEPT_FILE_SRC.@access_accept[$COUNTER].accept_mac`
	echo  "$MAC" >> $HAPD_ACCEPT_FILE
        
    let COUNTER=COUNTER+1
    done
    
    #Add DENY mac addr to file
    rm -f $HAPD_DENY_FILE
    touch $HAPD_DENY_FILE
    let COUNTER=0
    while [  $COUNTER -lt  $MAC_ADDR_DENY_NUM ]; do
    
	MAC=`uci get $DENY_FILE_SRC.@access_deny[$COUNTER].deny_mac`
	echo  "$MAC" >> $HAPD_DENY_FILE
	    
	let COUNTER=COUNTER+1
    done

    if [ $SECOND_SSID_ENABLED = "disable" ]; then
    	let EXIT_LOOP=1
    fi
    let SSID_NO=SSID_NO+1
    if [ $SSID_NO = 2 ];then 
    	let EXIT_LOOP=1
    fi
done
                                                                                                                
sync

if [ $1 = "1" ]; then
    echo "Changes need reboot..."
    sleep 1
    reboot
else
    echo "Changes don't need reboot"
    # trigger database update of UCI parameters                     
    db_writer -p probe1_update_trigger 1                                      
fi



#!/bin/sh

################################################################################################################
#################
# BACKUP CONFIG	#
#################
################################################################################################################

backup_wifi_ssid() {
	uci set $BACKUP_CONFIG_FILES.backup.ssid="$WIFI_SSID"
	uci set $BACKUP_CONFIG_FILES.backup.wifi_channel_select="$WIFI_CHANNEL_AUTO"
	uci set $BACKUP_CONFIG_FILES.backup.channel="$WIFI_CHANNEL"
	uci set $BACKUP_CONFIG_FILES.backup.wmm_enabled="$WIFI_WMM"
	uci set $BACKUP_CONFIG_FILES.backup.wifi_ignore_broadcast_ssid="$WIFI_BROADCAST"
	#restore extra ssid config
	uci set $BACKUP_CONFIG_FILES.backup.extra_ssid="$WIFI_EXTRA_SSID"
	uci commit $BACKUP_CONFIG_FILES
	sync
 
}

backup_wifi_ssid_2() {
	uci set $BACKUP_CONFIG_FILES.backup.ssid_2="$WIFI_SSID_2"
	uci set $BACKUP_CONFIG_FILES.backup.wifi_ignore_broadcast_ssid_2="$WIFI_BROADCAST_2"
	uci commit $BACKUP_CONFIG_FILES
	sync
 
}

backup_multipdn_enabled() {
	uci set $BACKUP_CONFIG_FILES.backup.multipdn="$MULT_PDN"
	uci commit $BACKUP_CONFIG_FILES
	sync	
}

backup_mac_filter() {

uci set $BACKUP_CONFIG_FILES.backup.macaddr_acl="$WIFI_MAC_FILTER"

if [ $WIFI_MAC_FILTER = "1" ];then
	cp $CONFIG_PATH/wifi-accept $BACKUP_CONFIG_DIR
	WIFI_MAC_FILTER_ACCEPT_COUNT=`uci get $CONFIG_PATH/wifi.wifi.accept_mac_num`
	uci set $BACKUP_CONFIG_FILES.backup.accept_mac_num="$WIFI_MAC_FILTER_ACCEPT_COUNT"
elif [ $WIFI_MAC_FILTER = "2" ];then
	cp $CONFIG_PATH/wifi-deny $BACKUP_CONFIG_DIR
	WIFI_MAC_FILTER_DENY_COUNT=`uci get $CONFIG_PATH/wifi.wifi.deny_mac_num`
	uci set $BACKUP_CONFIG_FILES.backup.deny_mac_num="$WIFI_MAC_FILTER_DENY_COUNT"
fi

uci commit $BACKUP_CONFIG_FILES
sync

}

backup_mac_filter_2() {

uci set $BACKUP_CONFIG_FILES.backup.macaddr_acl_2="$WIFI_MAC_FILTER_2"

if [ $WIFI_MAC_FILTER_2 = "1" ];then
	cp $CONFIG_PATH/wifi-second-accept $BACKUP_CONFIG_DIR
	WIFI_MAC_FILTER_ACCEPT_COUNT_2=`uci get $CONFIG_PATH/wifi-second.wifi.accept_mac_num`
	uci set $BACKUP_CONFIG_FILES.backup.accept_mac_num_2="$WIFI_MAC_FILTER_ACCEPT_COUNT_2"
elif [ $WIFI_MAC_FILTER_2 = "2" ];then
	cp $CONFIG_PATH/wifi-second-deny $BACKUP_CONFIG_DIR
	WIFI_MAC_FILTER_DENY_COUNT_2=`uci get $CONFIG_PATH/wifi-second.wifi.deny_mac_num`
	uci set $BACKUP_CONFIG_FILES.backup.deny_mac_num_2="$WIFI_MAC_FILTER_DENY_COUNT_2"
fi

uci commit $BACKUP_CONFIG_FILES
sync

}

backup_wifi_security() {

uci set $BACKUP_CONFIG_FILES.backup.sec_encryption="$WIFI_ENCRIPTION"

if [ $WIFI_ENCRIPTION = "wep" ]; then
	WEP_KEY0=`uci get $CONFIG_PATH/wifi.wifi.sec_wep_key0`
	WEP_KEY1=`uci get $CONFIG_PATH/wifi.wifi.sec_wep_key1`
	WEP_KEY2=`uci get $CONFIG_PATH/wifi.wifi.sec_wep_key2`
	WEP_KEY3=`uci get $CONFIG_PATH/wifi.wifi.sec_wep_key3`
	WEP_DEF=`uci get $CONFIG_PATH/wifi.wifi.sec_wep_default_key`
	WEP_TYPE=`uci get $CONFIG_PATH/wifi.wifi.set_wep_type`

	uci set $BACKUP_CONFIG_FILES.backup.sec_wep_key0="$WEP_KEY0"
	uci set $BACKUP_CONFIG_FILES.backup.sec_wep_key1="$WEP_KEY1"
	uci set $BACKUP_CONFIG_FILES.backup.sec_wep_key2="$WEP_KEY2"
	uci set $BACKUP_CONFIG_FILES.backup.sec_wep_key3="$WEP_KEY3"
	uci set $BACKUP_CONFIG_FILES.backup.sec_wep_default_key="$WEP_DEF"
	uci set $BACKUP_CONFIG_FILES.backup.set_wep_type="$WEP_TYPE"
elif [ $WIFI_ENCRIPTION = "wpa" ]; then
	WIFI_SEC=`uci get $CONFIG_PATH/wifi.wifi.sec_pass`
	uci set $BACKUP_CONFIG_FILES.backup.sec_pass="$WIFI_SEC"
elif [ $WIFI_ENCRIPTION = "wpa2" ]; then
	WIFI_SEC=`uci get $CONFIG_PATH/wifi.wifi.sec_pass`
    uci set $BACKUP_CONFIG_FILES.backup.sec_pass="$WIFI_SEC"
elif [ $WIFI_ENCRIPTION = "mixed-wpa-wpa2" ]; then
	WIFI_SEC=`uci get $CONFIG_PATH/wifi.wifi.sec_pass`
    uci set $BACKUP_CONFIG_FILES.backup.sec_pass="$WIFI_SEC"
fi

uci commit $BACKUP_CONFIG_FILES
sync
}


backup_wifi_security_2() {


uci set $BACKUP_CONFIG_FILES.backup.sec_encryption_2="$WIFI_ENCRIPTION_2"

if [ $WIFI_ENCRIPTION_2 = "wep" ]; then
	WEP_KEY0_2=`uci get $CONFIG_PATH/wifi-second.wifi.sec_wep_key0`
	WEP_KEY1_2=`uci get $CONFIG_PATH/wifi-second.wifi.sec_wep_key1`
	WEP_KEY2_2=`uci get $CONFIG_PATH/wifi-second.wifi.sec_wep_key2`
	WEP_KEY3_2=`uci get $CONFIG_PATH/wifi-second.wifi.sec_wep_key3`
	WEP_DEF_2=`uci get $CONFIG_PATH/wifi-second.wifi.sec_wep_default_key`
	WEP_TYPE_2=`uci get $CONFIG_PATH/wifi-second.wifi.set_wep_type`
	uci set $BACKUP_CONFIG_FILES.backup.sec_wep_key0_2="$WEP_KEY0_2"
	uci set $BACKUP_CONFIG_FILES.backup.sec_wep_key1_2="$WEP_KEY1_2"
	uci set $BACKUP_CONFIG_FILES.backup.sec_wep_key2_2="$WEP_KEY2_2"
	uci set $BACKUP_CONFIG_FILES.backup.sec_wep_key3_2="$WEP_KEY3_2"
	uci set $BACKUP_CONFIG_FILES.backup.sec_wep_default_key_2="$WEP_DEF_2"
	uci set $BACKUP_CONFIG_FILES.backup.set_wep_type_2="$WEP_TYPE_2"
elif [ $WIFI_ENCRIPTION_2 = "wpa" ]; then
	WIFI_SEC_2=`uci get $CONFIG_PATH/wifi-second.wifi.sec_pass`
	uci set $BACKUP_CONFIG_FILES.backup.sec_pass_2="$WIFI_SEC_2"
elif [ $WIFI_ENCRIPTION = "wpa2" ]; then
	WIFI_SEC_2=`uci get $CONFIG_PATH/wifi-second.wifi.sec_pass`
    uci set $BACKUP_CONFIG_FILES.backup.sec_pass_2="$WIFI_SEC_2"
elif [ $WIFI_ENCRIPTION = "mixed-wpa-wpa2" ]; then
	WIFI_SEC_2=`uci get $CONFIG_PATH/wifi-second.wifi.sec_pass`
    uci set $BACKUP_CONFIG_FILES.backup.sec_pass_2="$WIFI_SEC_2"
fi

uci commit $BACKUP_CONFIG_FILES
sync
}

backup_wifi_wps() {
	uci set $BACKUP_CONFIG_FILES.backup.wps_enabled="$WIFI_WPS"
	uci commit $BACKUP_CONFIG_FILES
	sync	
}

backup_login_pass() {
	uci set $BACKUP_CONFIG_FILES.backup.admin_id="$ADMIN_ID"
	uci set $BACKUP_CONFIG_FILES.backup.admin_pw="$ADMIN_PASSWD"
	uci commit $BACKUP_CONFIG_FILES
	sync	
}

backup_acs_config() {
	cp -rf $CONFIG_PATH/cpestate* $BACKUP_CONFIG_DIR
#//jwpark S 2014.11.30 fixed issue that Device does not retain the value set on SPV after reboot in RJIL-MiFiRouter-NTM_R100_R03.3_L1Report.xlsx.
	cp -rf $CONFIG_PATH/config.save $BACKUP_CONFIG_DIR
	if [ -f $CONFIG_PATH/cpeAttributeSave ];then
		cp -rf $CONFIG_PATH/cpeAttributeSave $BACKUP_CONFIG_DIR
	fi
#jclee,150223, block temporarily [START]
#	FACTORY_CONFIG_PATH=/etc/config_shadow
#	if [ -e $FACTORY_CONFIG_PATH/cpestate.xml ]; then
#		`grep "<acsUser>" $FACTORY_CONFIG_PATH/cpestate.xml > $BACKUP_CONFIG_DIR/ACS_Credential`
#		`grep "<acsPW>" $FACTORY_CONFIG_PATH/cpestate.xml >> $BACKUP_CONFIG_DIR/ACS_Credential`
#	fi
#jclee,150223, block temporarily [END]	
	sync
}

backup_redirect_config() {
	cp -rf $CONFIG_PATH/redirect* $BACKUP_CONFIG_DIR
	sync
}

backup_power_saving_time() {
	uci set $BACKUP_CONFIG_FILES.backup.no_station_timeout="$POWER_SAVING_TIME"
	uci commit $BACKUP_CONFIG_FILES
	sync
}


backup_firewall() {
	uci set $BACKUP_CONFIG_FILES.backup.firewall="$FIREWALL_EN"
	uci set $BACKUP_CONFIG_FILES.backup.firewall_ping="$FIREWALL_PING"
	uci set $BACKUP_CONFIG_FILES.backup.firwwall_httplogin="$FIREWALL_HTTP_LOGIN"
	uci set $BACKUP_CONFIG_FILES.backup.firwwall_httpport="$FIREWALL_PORT"
	uci set $BACKUP_CONFIG_FILES.backup.firewall_icmp="$FIREWALL_ICMP"
	uci commit $BACKUP_CONFIG_FILES
        sync
}

backup_dmz(){
	uci set $BACKUP_CONFIG_FILES.backup.dmz_enable="$DMZ_EN"
	uci set $BACKUP_CONFIG_FILES.backup.dmz_host_ip="$DMZ_IPADDR"
	uci commit $BACKUP_CONFIG_FILES
	sync

}

backup_dhcp(){
	uci set $BACKUP_CONFIG_FILES.backup.host_reservation_num="$DHCP_RES_COUNT"
	uci set $BACKUP_CONFIG_FILES.backup.dhcp_enable="$DHCP_EN"
	uci set $BACKUP_CONFIG_FILES.backup.dhcp_range_from_ip="$DHCP_FROM_RANGE"
	uci set $BACKUP_CONFIG_FILES.backup.dhcp_range_to_ip="$DHCP_TO_RANGE"
	uci set $BACKUP_CONFIG_FILES.backup.dhcp_lease_time="$DHCP_LEASE_TIME"
	uci set $BACKUP_CONFIG_FILES.backup.dhcp_pri_enable="$DHCP_DNS_PRI_EN"
	uci set $BACKUP_CONFIG_FILES.backup.dhcp_sec_enable="$DHCP_DNS_SEC_EN"

	if [ $DHCP_DNS_PRI_EN != "false" ];then
		uci set $BACKUP_CONFIG_FILES.backup.dhcp_pri_back="$DHCP_DNS_PRI_BACK"
	fi

        if [ $DHCP_DNS_SEC_EN != "false" ];then
                uci set $BACKUP_CONFIG_FILES.backup.dhcp_sec_back="$DHCP_DNS_SEC_BACK"
        fi

        uci commit $BACKUP_CONFIG_FILES
	sync

	cp -rf $CONFIG_PATH/lte-gw-dhcp-hosts $BACKUP_CONFIG_DIR
	sync

}

backup_portforwarding(){

	uci set $BACKUP_CONFIG_FILES.backup.port_fwd_num="$NAT_FORT_FWD_COUNT"

	uci commit $BACKUP_CONFIG_FILES
        sync

	cp -rf $CONFIG_PATH/lte-gw-port-fwd $BACKUP_CONFIG_DIR
	sync

}

backup_wifi(){

	uci set $BACKUP_CONFIG_FILES.backup.wifi_technology="$WIFI_TECH"
	uci set $BACKUP_CONFIG_FILES.backup.wifi_tx_power="$WIFI_TX_POWER"
	uci set $BACKUP_CONFIG_FILES.backup.wifi_wmm_enabled="$WIFI_WMM"
	uci set $BACKUP_CONFIG_FILES.backup.wifi_ignore_broadcast_ssid="$WIFI_BROADCAST"

    sync
	if [ $WIFI_EXTRA_SSID == "enable" ];then
		uci set $BACKUP_CONFIG_FILES.backup.wifi_ignore_broadcast_ssid_2="$WIFI_BROADCAST_2"
	fi
	
	uci commit $BACKUP_CONFIG_FILES
}

backup_usage(){

	if [ -d $CONFIG_PATH/db ];then
		mkdir -p $BACKUP_CONFIG_DIR/db/
		cp -rf $CONFIG_PATH/db/* $BACKUP_CONFIG_DIR/db/
	fi

	if [ -d $CONFIG_PATH/db_backup ];then
		mkdir -p $BACKUP_CONFIG_DIR/db_backup/
		cp -rf $CONFIG_PATH/db_backup/* $BACKUP_CONFIG_DIR/db_backup/
	fi
	uci set $BACKUP_CONFIG_FILES.backup.billing_date="$BILLING_DATE"
	uci commit $BACKUP_CONFIG_FILES
	sync
}



################################################################################################################
##################
# RESTORE CONFIG #
##################
################################################################################################################

restore_wifi_ssid() {
	uci set $CONFIG_PATH/wifi.wifi.ssid="$BACKUP_WIFI_SSID"
	uci set $CONFIG_PATH/wifi.wifi.wifi_channel_select="$BACKUP_WIFI_CHANNEL_AUTO"
	uci set $CONFIG_PATH/wifi.wifi.channel="$BACKUP_WIFI_CHANNEL"
	uci set $CONFIG_PATH/wifi.wifi.wmm_enabled="$BACKUP_WIFI_WMM"
	uci set $CONFIG_PATH/wifi.wifi.ignore_broadcast_ssid="$BACKUP_WIFI_BROADCAST"
	uci commit $CONFIG_PATH/wifi
	#restore extra ssid config
	uci set $CONFIG_PATH/wifi-second.wifi_start.second_ssid_enabled="$BACKUP_WIFI_EXTRA_SSID"
	uci commit $CONFIG_PATH/wifi-second
	sync
		
}

restore_wifi_ssid_2() {
	uci set $CONFIG_PATH/wifi-second.wifi.ssid="$BACKUP_WIFI_SSID_2"
	uci set $CONFIG_PATH/wifi-second.wifi.ignore_broadcast_ssid="$BACKUP_WIFI_BROADCAST_2"
	uci commit $CONFIG_PATH/wifi-second
	sync
}

restore_multipdn_enabled() {
	uci set $CONFIG_PATH/APNTable.Class2.Enabled="$BACKUP_MULT_PDN"
	uci commit $CONFIG_PATH/APNTable
	sync
}

restore_mac_filter() {

uci set $CONFIG_PATH/wifi.wifi.macaddr_acl="$BACKUP_WIFI_MAC_FILTER"

if [ $BACKUP_WIFI_MAC_FILTER = "1" ];then
	cp -rf $BACKUP_CONFIG_DIR/wifi-accept $CONFIG_PATH
	BACKUP_WIFI_MAC_FILTER_ACCEPT_COUNT=`uci get $BACKUP_CONFIG_FILES.backup.accept_mac_num`
	uci set $CONFIG_PATH/wifi.wifi.accept_mac_num="$BACKUP_WIFI_MAC_FILTER_ACCEPT_COUNT"
elif [ $BACKUP_WIFI_MAC_FILTER = "2" ];then
	cp -rf $BACKUP_CONFIG_DIR/wifi-deny $CONFIG_PATH
	BACKUP_WIFI_MAC_FILTER_DENY_COUNT=`uci get $BACKUP_CONFIG_FILES.backup.deny_mac_num`
	uci set $CONFIG_PATH/wifi.wifi.deny_mac_num="$BACKUP_WIFI_MAC_FILTER_DENY_COUNT"
fi

uci commit $CONFIG_PATH/wifi
sync

}

restore_mac_filter_2() {

uci set $CONFIG_PATH/wifi-second.wifi.macaddr_acl="$BACKUP_WIFI_MAC_FILTER_2"

if [ $BACKUP_WIFI_MAC_FILTER_2 = "1" ];then
	cp -rf $BACKUP_CONFIG_DIR/wifi-second-accept $CONFIG_PATH
	BACKUP_WIFI_MAC_FILTER_ACCEPT_COUNT_2=`uci get $BACKUP_CONFIG_FILES.backup.accept_mac_num_2`
	uci set $CONFIG_PATH/wifi-second.wifi.accept_mac_num="$BACKUP_WIFI_MAC_FILTER_ACCEPT_COUNT_2"
elif [ $BACKUP_WIFI_MAC_FILTER_2 = "2" ];then
	cp -rf $BACKUP_CONFIG_DIR/wifi-second-deny $CONFIG_PATH
	BACKUP_WIFI_MAC_FILTER_DENY_COUNT_2=`uci get $BACKUP_CONFIG_FILES.backup.deny_mac_num_2`
	uci set $CONFIG_PATH/wifi-second.wifi.deny_mac_num="$BACKUP_WIFI_MAC_FILTER_DENY_COUNT_2"
fi

uci commit $CONFIG_PATH/wifi-second
sync

}

restore_wifi_security() {

uci set $CONFIG_PATH/wifi.wifi.sec_encryption="$BACKUP_WIFI_ENCRIPTION"

if [ $BACKUP_WIFI_ENCRIPTION = "wep" ]; then
	BACKUP_WEP_KEY0=`uci get $BACKUP_CONFIG_FILES.backup.sec_wep_key0`
	BACKUP_WEP_KEY1=`uci get $BACKUP_CONFIG_FILES.backup.sec_wep_key1`
	BACKUP_WEP_KEY2=`uci get $BACKUP_CONFIG_FILES.backup.sec_wep_key2`
	BACKUP_WEP_KEY3=`uci get $BACKUP_CONFIG_FILES.backup.sec_wep_key3`
	BACKUP_WEP_DEF=`uci get $BACKUP_CONFIG_FILES.backup.sec_wep_default_key`
	BACKUP_WEP_TYPE=`uci get $BACKUP_CONFIG_FILES.backup.set_wep_type`

	uci set $CONFIG_PATH/wifi.wifi.sec_wep_key0="$BACKUP_WEP_KEY0"
	uci set $CONFIG_PATH/wifi.wifi.sec_wep_key1="$BACKUP_WEP_KEY1"
	uci set $CONFIG_PATH/wifi.wifi.sec_wep_key2="$BACKUP_WEP_KEY2"
	uci set $CONFIG_PATH/wifi.wifi.sec_wep_key3="$BACKUP_WEP_KEY3"
	uci set $CONFIG_PATH/wifi.wifi.sec_wep_default_key="$BACKUP_WEP_DEF"
	uci set $CONFIG_PATH/wifi.wifi.set_wep_type="$BACKUP_WEP_TYPE"

elif [ $BACKUP_WIFI_ENCRIPTION = "wpa" ]; then
	BACKUP_WIFI_SEC=`uci get $BACKUP_CONFIG_FILES.backup.sec_pass`
	uci set $CONFIG_PATH/wifi.wifi.sec_pass="$BACKUP_WIFI_SEC"

elif [ $BACKUP_WIFI_ENCRIPTION = "wpa2" ]; then
	BACKUP_WIFI_SEC=`uci get $BACKUP_CONFIG_FILES.backup.sec_pass`
	uci set $CONFIG_PATH/wifi.wifi.sec_pass="$BACKUP_WIFI_SEC"

elif [ $BACKUP_WIFI_ENCRIPTION = "mixed-wpa-wpa2" ]; then
	BACKUP_WIFI_SEC=`uci get $BACKUP_CONFIG_FILES.backup.sec_pass`
	uci set $CONFIG_PATH/wifi.wifi.sec_pass="$BACKUP_WIFI_SEC"
fi

uci commit $CONFIG_PATH/wifi
sync

}

restore_wifi_security_2() {

uci set $CONFIG_PATH/wifi-second.wifi.sec_encryption="$BACKUP_WIFI_ENCRIPTION_2"

if [ $BACKUP_WIFI_ENCRIPTION_2 = "wep" ]; then
	BACKUP_WEP_KEY0_2=`uci get $BACKUP_CONFIG_FILES.backup.sec_wep_key0_2`
	BACKUP_WEP_KEY1_2=`uci get $BACKUP_CONFIG_FILES.backup.sec_wep_key1_2`
	BACKUP_WEP_KEY2_2=`uci get $BACKUP_CONFIG_FILES.backup.sec_wep_key2_2`
	BACKUP_WEP_KEY3_2=`uci get $BACKUP_CONFIG_FILES.backup.sec_wep_key3_2`
	BACKUP_WEP_DEF_2=`uci get $BACKUP_CONFIG_FILES.backup.sec_wep_default_key_2`

	uci set $CONFIG_PATH/wifi-second.wifi.sec_wep_key0="$BACKUP_WEP_KEY0_2"
	uci set $CONFIG_PATH/wifi-second.wifi.sec_wep_key1="$BACKUP_WEP_KEY1_2"
	uci set $CONFIG_PATH/wifi-second.wifi.sec_wep_key2="$BACKUP_WEP_KEY2_2"
	uci set $CONFIG_PATH/wifi-second.wifi.sec_wep_key3="$BACKUP_WEP_KEY3_2"
	uci set $CONFIG_PATH/wifi-second.wifi.sec_wep_default_key="$BACKUP_WEP_DEF_2"

elif [ $BACKUP_WIFI_ENCRIPTION_2 = "wpa" ]; then
	BACKUP_WIFI_SEC_2=`uci get $BACKUP_CONFIG_FILES.backup.sec_pass_2`
	uci set $CONFIG_PATH/wifi-second.wifi.sec_pass="$BACKUP_WIFI_SEC_2"

elif [ $BACKUP_WIFI_ENCRIPTION_2 = "wpa2" ]; then
	BACKUP_WIFI_SEC_2=`uci get $BACKUP_CONFIG_FILES.backup.sec_pass_2`
	uci set $CONFIG_PATH/wifi-second.wifi.sec_pass="$BACKUP_WIFI_SEC_2"

elif [ $BACKUP_WIFI_ENCRIPTION_2 = "mixed-wpa-wpa2" ]; then
	BACKUP_WIFI_SEC_2=`uci get $BACKUP_CONFIG_FILES.backup.sec_pass_2_2`
	uci set $CONFIG_PATH/wifi-second.wifi.sec_pass="$BACKUP_WIFI_SEC_2"
fi

uci commit $CONFIG_PATH/wifi-second
sync

}



restore_wifi_wps() {
	uci set $CONFIG_PATH/wifi.wifi.wps_enabled="$BACKUP_WIFI_WPS"
	uci commit $CONFIG_PATH/wifi
	sync
}

restore_login_pass() {
        ADMIN_ID_CNT=`echo $BACKUP_ADMIN_ID | wc -L`
        if [ $ADMIN_ID_CNT -eq 0 ]
        then
          echo "ADMIN_ID_CNT is null"
        else
          uci set $CONFIG_PATH/login_info.passwd.admin_id="$BACKUP_ADMIN_ID"
        fi
	uci set $CONFIG_PATH/login_info.passwd.admin_pw="$BACKUP_ADMIN_PASSWD"
	uci commit $CONFIG_PATH/login_info
	sync
}

restore_acs_config() {
	cp -rf $BACKUP_CONFIG_DIR/cpestate* $CONFIG_PATH
#//jwpark S 2014.11.30 fixed issue that Device does not retain the value set on SPV after reboot in RJIL-MiFiRouter-NTM_R100_R03.3_L1Report.xlsx
	cp -rf $BACKUP_CONFIG_DIR/config.save $CONFIG_PATH
	if [ -f $BACKUP_CONFIG_DIR/cpeAttributeSave ];then
		cp -rf $BACKUP_CONFIG_DIR/cpeAttributeSave $CONFIG_PATH
		sync
	fi

#	CURRENT_URL=`grep "<acsURL>" $CONFIG_PATH/cpestate.xml`
#	NEW_URL=`grep "<acsURL>" /etc/config_shadow/cpestate.xml`

#jclee,150223, block temporarily [START]
#	SHADOW_CONFIG_PATH=/etc/config_shadow
#	if [ -e $BACKUP_CONFIG_DIR/ACS_Credential ] && [ -e $SHADOW_CONFIG_PATH/cpestate.xml ]; then
#		DEFAULT_ACS_USER=`grep "<acsUser>" $BACKUP_CONFIG_DIR/ACS_Credential`
#		DEFAULT_ACS_PW=`grep "<acsPW>" $BACKUP_CONFIG_DIR/ACS_Credential`
#		NEW_ACS_USER=`grep "<acsUser>" $SHADOW_CONFIG_PATH/cpestate.xml`
#		NEW_ACS_PW=`grep "<acsPW>" $SHADOW_CONFIG_PATH/cpestate.xml`

#		if [ $DEFAULT_ACS_USER != $NEW_ACS_USER ] || [ $DEFAULT_ACS_PW != $NEW_ACS_PW ]; then
#			echo "_________________ Changed ACS Credential _________________"
#			echo "DEFAULT_ACS_USER = $DEFAULT_ACS_USER , DEFAULT_ACS_PW = $DEFAULT_ACS_PW"
#			echo "NEW_ACS_USER     = $NEW_ACS_USER     , NEW_ACS_PW     = $NEW_ACS_PW"
#			touch /etc/config/Changed_ACS_Credential
#		fi
#	fi
#	sync
#jclee,150223, block temporarily [END]

#	CURRENT_URL=`grep "<acsURL>" $CONFIG_PATH/cpestate.xml`
#	NEW_URL=`grep "<acsURL>" /etc/config_shadow/cpestate.xml`
#	if [ $CURRENT_URL != $NEW_URL ]; then
#		cp -rf /etc/config_shadow/cpestate* $CONFIG_PATH/
#		sync
#		echo "[ Change ACS Server URL ]"
#		rm -rf /nvm/tr069_fw_update
#	fi
}

restore_redirect_config() {
	cp -rf $BACKUP_CONFIG_DIR/redirect* $CONFIG_PATH/
        sync
}

restore_power_saving_time() {
	uci set $CONFIG_PATH/pm_statemachine.wifi_mon.no_station_timeout="$BACKUP_POWER_SAVING_TIME"
	uci commit $CONFIG_PATH/pm_statemachine
	sync
}

restore_firewall() {

	uci set $CONFIG_PATH/firewall.config.firewall="$BACKUP_FIREWALL_EN"
	uci set $CONFIG_PATH/firewall.config.ping="$BACKUP_FIREWALL_PING"
	uci set $CONFIG_PATH/firewall.config.httplogin="$BACKUP_FIREWALL_HTTP_LOGIN"
	uci set $CONFIG_PATH/firewall.config.http_port="$BACKUP_FIREWALL_PORT"
	uci set $CONFIG_PATH/firewall.config.icmp="$BACKUP_FIREWALL_ICMP"

	uci commit $CONFIG_PATH/firewall
	sync
}

restore_dmz(){

	uci set $CONFIG_PATH/lte-gw.nat.dmz_enable="$BACKUP_DMZ_EN"
	uci set $CONFIG_PATH/lte-gw.nat.dmz_host_ip="$BACKUP_DMZ_IPADDR"

	uci commit $CONFIG_PATH/lte-gw
	sync
}

restore_dhcp(){

    if [ $BACKUP_DHCP_EN != '' ]; then
	uci set $CONFIG_PATH/lte-gw.dhcp_srv.host_reservation_num="$BACKUP_DHCP_RES_COUNT"
	uci set $CONFIG_PATH/lte-gw.dhcp_srv.dhcp_enable="$BACKUP_DHCP_EN"
	uci set $CONFIG_PATH/lte-gw.dhcp_srv.range_from_ip="$BACKUP_DHCP_FROM_RANGE"
	uci set $CONFIG_PATH/lte-gw.dhcp_srv.range_to_ip="$BACKUP_DHCP_TO_RANGE"
	uci set $CONFIG_PATH/lte-gw.dhcp_srv.lease_time_min="$BACKUP_DHCP_LEASE_TIME"
	fi

	uci set $CONFIG_PATH/lte-gw.dhcp_srv.pri_enable="$BACKUP_DHCP_DNS_PRI_EN"

	if [ $BACKUP_DHCP_DNS_PRI_EN != "false" ];then
		uci set $CONFIG_PATH/lte-gw.dhcp_srv.pri_back="$BACKUP_DHCP_DNS_PRI_BACK"
	fi

	uci set $CONFIG_PATH/lte-gw.dhcp_srv.sec_enable="$BACKUP_DHCP_DNS_SEC_EN"

	if [ $BACKUP_DHCP_DNS_SEC_EN != "false" ];then
		uci set $CONFIG_PATH/lte-gw.dhcp_srv.sec_back="$BACKUP_DHCP_DNS_SEC_BACK"
	fi

	uci commit $CONFIG_PATH/lte-gw

	cp -rf $BACKUP_CONFIG_DIR/lte-gw-dhcp-hosts $CONFIG_PATH

        sync

}

restore_portforwarding(){

	uci set $CONFIG_PATH/lte-gw.nat.port_fwd_num="$BACKUP_NAT_FORT_FWD_COUNT"

	uci commit $CONFIG_PATH/lte-gw

        cp -rf $BACKUP_CONFIG_DIR/lte-gw-port-fwd $CONFIG_PATH

	sync
	
}

restore_wifi(){


	uci set $CONFIG_PATH/wifi.wifi.technology="$BACKUP_WIFI_TECH"
	uci set $CONFIG_PATH/wifi.wifi.tx_power="$BACKUP_WIFI_TX_POWER"
	uci set $CONFIG_PATH/wifi.wifi.wmm_enabled="$BACKUP_WIFI_WMM"
	uci set $CONFIG_PATH/wifi.wifi.ignore_broadcast_ssid="$BACKUP_WIFI_BROADCAST"

	uci commit $CONFIG_PATH/wifi

	sync

}

restore_usage(){
	if [ -d $BACKUP_CONFIG_DIR/db ];then
		cp -rf $BACKUP_CONFIG_DIR/db $CONFIG_PATH
	fi
	if [ -d $BACKUP_CONFIG_DIR/db_backup ];then
		cp -rf $BACKUP_CONFIG_DIR/db_backup $CONFIG_PATH
	fi

	BACKUP_BILLING_DATE_CNT=`echo $BACKUP_BILLING_DATE | wc -L`
        if [ $BACKUP_BILLING_DATE_CNT -eq 0 ]
        then
          echo "BACKUP_BILLING_DATE_CNT is null"
	  uci set $CONFIG_PATH/web_info.info.billing_date="1"
        else
	  uci set $CONFIG_PATH/web_info.info.billing_date="$BACKUP_BILLING_DATE"
        fi

	uci commit $CONFIG_PATH/web_info
        sync
}



case "$1" in

	backup)

		CONFIG_PATH="/etc/config"
		BACKUP_CONFIG_DIR="/nvm/etc/backup_config"
		BACKUP_CONFIG_FILES="$BACKUP_CONFIG_DIR/backup_config"
		DHCP_RES_COUNT=`uci get $CONFIG_PATH/lte-gw.dhcp_srv.host_reservation_num`
		DHCP_EN=`uci get $CONFIG_PATH/lte-gw.dhcp_srv.dhcp_enable`
		DHCP_FROM_RANGE=`uci get $CONFIG_PATH/lte-gw.dhcp_srv.range_from_ip`
		DHCP_TO_RANGE=`uci get $CONFIG_PATH/lte-gw.dhcp_srv.range_to_ip`
		DHCP_LEASE_TIME=`uci get $CONFIG_PATH/lte-gw.dhcp_srv.lease_time_min`
		MULT_PDN=`uci get $CONFIG_PATH/APNTable.Class2.Enabled`       
		WIFI_SSID=`uci get $CONFIG_PATH/wifi.wifi.ssid`
		WIFI_CHANNEL_AUTO=`uci get $CONFIG_PATH/wifi.wifi.wifi_channel_select`
		WIFI_CHANNEL=`uci get $CONFIG_PATH/wifi.wifi.channel`
		WIFI_WMM=`uci get $CONFIG_PATH/wifi.wifi.wmm_enabled`
		WIFI_BROADCAST=`uci get $CONFIG_PATH/wifi.wifi.ignore_broadcast_ssid`               
		WIFI_MAC_FILTER=`uci get $CONFIG_PATH/wifi.wifi.macaddr_acl`  
		WIFI_ENCRIPTION=`uci get $CONFIG_PATH/wifi.wifi.sec_encryption` 
		WIFI_WPS=`uci get $CONFIG_PATH/wifi.wifi.wps_enabled`
		WIFI_EXTRA_SSID=`uci get $CONFIG_PATH/wifi-second.wifi_start.second_ssid_enabled`

		# backup extra ssid
		if [ $WIFI_EXTRA_SSID == "enable" ];then
			WIFI_SSID_2=`uci get $CONFIG_PATH/wifi-second.wifi.ssid`
			WIFI_BROADCAST_2=`uci get $CONFIG_PATH/wifi-second.wifi.ignore_broadcast_ssid`               
			WIFI_MAC_FILTER_2=`uci get $CONFIG_PATH/wifi-second.wifi.macaddr_acl`  
			WIFI_ENCRIPTION_2=`uci get $CONFIG_PATH/wifi-second.wifi.sec_encryption` 
		fi
		ADMIN_ID=`uci get $CONFIG_PATH/login_info.passwd.admin_id`         
		ADMIN_PASSWD=`uci get $CONFIG_PATH/login_info.passwd.admin_pw`
		POWER_SAVING_TIME=`uci get $CONFIG_PATH/pm_statemachine.wifi_mon.no_station_timeout`
		BILLING_DATE=`uci get $CONFIG_PATH/web_info.info.billing_date`

		if [ ! -f $BACKUP_CONFIG_FILES ];then

			mkdir -p $BACKUP_CONFIG_DIR

			echo "config 'Environment' 'backup'" > $BACKUP_CONFIG_FILES
		else
			rm -rf $BACKUP_CONFIG_DIR/*

			echo "config 'Environment' 'backup'" > $BACKUP_CONFIG_FILES
		fi

		backup_wifi_ssid
		backup_multipdn_enabled
		backup_mac_filter
		backup_wifi_security
		backup_wifi_wps
		# backup extra ssid
		if [ $WIFI_EXTRA_SSID == "enable" ];then
			backup_wifi_ssid_2
			backup_mac_filter_2
			backup_wifi_security_2
		fi		
		backup_login_pass
		backup_acs_config
#		backup_redirect_config
		backup_power_saving_time
		backup_usage
		backup_dhcp

		cp -rf $CONFIG_PATH/APNTable $BACKUP_CONFIG_DIR
		cp -rf $CONFIG_PATH/lte_auth $BACKUP_CONFIG_DIR

		;;

	restore)

		CONFIG_PATH="/etc/config"
		BACKUP_CONFIG_DIR="/nvm/etc/backup_config"
		BACKUP_CONFIG_FILES="$BACKUP_CONFIG_DIR/backup_config"
		BACKUP_DHCP_RES_COUNT=`uci get $BACKUP_CONFIG_FILES.backup.host_reservation_num`
		BACKUP_DHCP_EN=`uci get $BACKUP_CONFIG_FILES.backup.dhcp_enable`
		BACKUP_DHCP_FROM_RANGE=`uci get $BACKUP_CONFIG_FILES.backup.dhcp_range_from_ip`
		BACKUP_DHCP_TO_RANGE=`uci get $BACKUP_CONFIG_FILES.backup.dhcp_range_to_ip`
		BACKUP_DHCP_LEASE_TIME=`uci get $BACKUP_CONFIG_FILES.backup.dhcp_lease_time`
		BACKUP_WIFI_SSID=`uci get $BACKUP_CONFIG_FILES.backup.ssid`
		BACKUP_WIFI_CHANNEL_AUTO=`uci get $BACKUP_CONFIG_FILES.backup.wifi_channel_select`
		BACKUP_WIFI_CHANNEL=`uci get $BACKUP_CONFIG_FILES.backup.channel`
		BACKUP_WIFI_WMM=`uci get $BACKUP_CONFIG_FILES.backup.wmm_enabled`
		BACKUP_WIFI_BROADCAST=`uci get $BACKUP_CONFIG_FILES.backup.wifi_ignore_broadcast_ssid`
		BACKUP_MULT_PDN=`uci get $BACKUP_CONFIG_FILES.backup.multipdn`
		BACKUP_WIFI_MAC_FILTER=`uci get $BACKUP_CONFIG_FILES.backup.macaddr_acl`
		BACKUP_WIFI_ENCRIPTION=`uci get $BACKUP_CONFIG_FILES.backup.sec_encryption`
		BACKUP_WIFI_WPS=`uci get $BACKUP_CONFIG_FILES.backup.wps_enabled`
		# restore extra ssid
		BACKUP_WIFI_EXTRA_SSID=`uci get $BACKUP_CONFIG_FILES.backup.extra_ssid`
		if [ $BACKUP_WIFI_EXTRA_SSID == "enable" ];then
			BACKUP_WIFI_SSID_2=`uci get $BACKUP_CONFIG_FILES.backup.ssid_2`
			BACKUP_WIFI_BROADCAST_2=`uci get $BACKUP_CONFIG_FILES.backup.wifi_ignore_broadcast_ssid_2`
			BACKUP_WIFI_MAC_FILTER_2=`uci get $BACKUP_CONFIG_FILES.backup.macaddr_acl_2`
			BACKUP_WIFI_ENCRIPTION_2=`uci get $BACKUP_CONFIG_FILES.backup.sec_encryption_2`
		fi
		BACKUP_ADMIN_ID=`uci get $BACKUP_CONFIG_FILES.backup.admin_id`
		BACKUP_ADMIN_PASSWD=`uci get $BACKUP_CONFIG_FILES.backup.admin_pw`
		BACKUP_POWER_SAVING_TIME=`uci get $BACKUP_CONFIG_FILES.backup.no_station_timeout`
		BACKUP_BILLING_DATE=`uci get $BACKUP_CONFIG_FILES.backup.billing_date`

		restore_wifi_ssid
		restore_multipdn_enabled
		restore_mac_filter
		restore_wifi_security
		restore_wifi_wps
		# restore extra ssid		
		if [ $BACKUP_WIFI_EXTRA_SSID == "enable" ];then
			restore_wifi_ssid_2
			restore_mac_filter_2
			restore_wifi_security_2
		fi
		restore_login_pass
		restore_acs_config
		#restore_redirect_config
		restore_power_saving_time
		restore_usage
		restore_dhcp

#		cp -rf $BACKUP_CONFIG_DIR/APNTable $CONFIG_PATH

		rm -rf $BACKUP_CONFIG_DIR/*

		sync

		# The LTE connection is established before confige file restore.
		# The LTE is connected with "common" network always after firmware update.
		# LTE connection time : before 8 seconds
		# Restore configuration : after 14 seconds
#		reboot

		;;


	uibackup) #for config.bin
		CONFIG_PATH="/etc/config"
		BACKUP_CONFIG_DIR="/nvm/etc/backup_config"
		BACKUP_CONFIG_FILES="$BACKUP_CONFIG_DIR/backup_config"

		FIREWALL_EN=`uci get $CONFIG_PATH/firewall.config.firewall`
		FIREWALL_PING=`uci get $CONFIG_PATH/firewall.config.ping`
		FIREWALL_HTTP_LOGIN=`uci get $CONFIG_PATH/firewall.config.http`
		FIREWALL_PORT=`uci get $CONFIG_PATH/firewall.config.http_port`
		FIREWALL_ICMP=`uci get $CONFIG_PATH/firewall.config.icmp`

		DMZ_EN=`uci get $CONFIG_PATH/lte-gw.nat.dmz_enable`
		DMZ_IPADDR=`uci get $CONFIG_PATH/lte-gw.nat.dmz_host_ip`

		DHCP_RES_COUNT=`uci get $CONFIG_PATH/lte-gw.dhcp_srv.host_reservation_num`
		DHCP_EN=`uci get $CONFIG_PATH/lte-gw.dhcp_srv.dhcp_enable`
		DHCP_FROM_RANGE=`uci get $CONFIG_PATH/lte-gw.dhcp_srv.range_from_ip`
		DHCP_TO_RANGE=`uci get $CONFIG_PATH/lte-gw.dhcp_srv.range_to_ip`
		DHCP_LEASE_TIME=`uci get $CONFIG_PATH/lte-gw.dhcp_srv.lease_time_min`
		DHCP_DNS_PRI_EN=`uci get $CONFIG_PATH/lte-gw.dhcp_srv.pri_enable`
		DHCP_DNS_SEC_EN=`uci get $CONFIG_PATH/lte-gw.dhcp_srv.sec_enable`
		if [ $DHCP_DNS_PRI_EN != "false" ];then
			DHCP_DNS_PRI_BACK=`uci get $CONFIG_PATH/lte-gw.dhcp_srv.pri_back`
		fi		

		if [ $DHCP_DNS_SEC_EN != "false" ];then
			DHCP_DNS_SEC_BACK=`uci get $CONFIG_PATH/lte-gw.dhcp_srv.sec_back`
		fi

		NAT_FORT_FWD_COUNT=`uci get $CONFIG_PATH/lte-gw.nat.port_fwd_num`

		WIFI_TECH=`uci get $CONFIG_PATH/wifi.wifi.technology`
		WIFI_TX_POWER=`uci get $CONFIG_PATH/wifi.wifi.tx_power`
		WIFI_WMM=`uci get $CONFIG_PATH/wifi.wifi.wmm_enabled`
		WIFI_BROADCAST=`uci get $CONFIG_PATH/wifi.wifi.ignore_broadcast_ssid`
		WIFI_EXTRA_SSID=`uci get $CONFIG_PATH/wifi-second.wifi_start.second_ssid_enabled`

		# backup extra ssid
		if [ $WIFI_EXTRA_SSID == "enable" ];then
			WIFI_BROADCAST_2=`uci get $CONFIG_PATH/wifi-second.wifi.ignore_broadcast_ssid`
		fi

        if [ ! -f $BACKUP_CONFIG_FILES ];then

            mkdir -p $BACKUP_CONFIG_DIR

            echo "config 'Environment' 'backup'" > $BACKUP_CONFIG_FILES
        fi

		backup_firewall
		backup_dmz	
		backup_dhcp
		backup_portforwarding
		backup_wifi
		;;

	uirestore)
		CONFIG_PATH="/etc/config"
		BACKUP_CONFIG_DIR="/nvm/etc/backup_config"
		BACKUP_CONFIG_FILES="$BACKUP_CONFIG_DIR/backup_config"
		BACKUP_FIREWALL_EN=`uci get $BACKUP_CONFIG_FILES.backup.firewall`
		BACKUP_FIREWALL_PING=`uci get $BACKUP_CONFIG_FILES.backup.firewall_ping`
		BACKUP_FIREWALL_HTTP_LOGIN=`uci get $BACKUP_CONFIG_FILES.backup.firwwall_httplogin`
		BACKUP_FIREWALL_PORT=`uci get $BACKUP_CONFIG_FILES.backup.firwwall_httpport`
		BACKUP_FIREWALL_ICMP=`uci get $BACKUP_CONFIG_FILES.backup.firewall_icmp`
		
		BACKUP_DMZ_EN=`uci get $BACKUP_CONFIG_FILES.backup.dmz_enable`
		BACKUP_DMZ_IPADDR=`uci get $BACKUP_CONFIG_FILES.backup.dmz_host_ip`

		BACKUP_DHCP_RES_COUNT=`uci get $BACKUP_CONFIG_FILES.backup.host_reservation_num`
		BACKUP_DHCP_EN=`uci get $BACKUP_CONFIG_FILES.backup.dhcp_enable`
		BACKUP_DHCP_FROM_RANGE=`uci get $BACKUP_CONFIG_FILES.backup.dhcp_range_from_ip`
		BACKUP_DHCP_TO_RANGE=`uci get $BACKUP_CONFIG_FILES.backup.dhcp_range_to_ip`
		BACKUP_DHCP_LEASE_TIME=`uci get $BACKUP_CONFIG_FILES.backup.dhcp_lease_time`
		BACKUP_DHCP_DNS_PRI_EN=`uci get $BACKUP_CONFIG_FILES.backup.dhcp_pri_enable`
		if [ $BACKUP_DHCP_DNS_PRI_EN != "false" ];then
			BACKUP_DHCP_DNS_PRI_BACK=`uci get $BACKUP_CONFIG_FILES.backup.dhcp_pri_back`
		fi

		BACKUP_DHCP_DNS_SEC_EN=`uci get $BACKUP_CONFIG_FILES.backup.dhcp_sec_enable`
		if [ $BACKUP_DHCP_DNS_SEC_EN != "false" ];then
			BACKUP_DHCP_DNS_SEC_BACK=`uci get $BACKUP_CONFIG_FILES.backup.dhcp_sec_back`
		fi

		BACKUP_NAT_FORT_FWD_COUNT=`uci get $BACKUP_CONFIG_FILES.backup.port_fwd_num`
		BACKUP_WIFI_TECH=`uci get $BACKUP_CONFIG_FILES.backup.wifi_technology`
		BACKUP_WIFI_TX_POWER=`uci get $BACKUP_CONFIG_FILES.backup.wifi_tx_power`
		BACKUP_WIFI_WMM=`uci get $BACKUP_CONFIG_FILES.backup.wifi_wmm_enabled`
		BACKUP_WIFI_BROADCAST=`uci get $BACKUP_CONFIG_FILES.backup.wifi_ignore_broadcast_ssid`
		BACKUP_WIFI_EXTRA_SSID=`uci get $BACKUP_CONFIG_FILES.backup.extra_ssid`
		if [ $BACKUP_WIFI_EXTRA_SSID == "enable" ];then				
			BACKUP_WIFI_BROADCAST_2=`uci get $BACKUP_CONFIG_FILES.backup.wifi_ignore_broadcast_ssid_2`
		fi
		restore_firewall
		restore_dmz
		restore_dhcp
		restore_portforwarding
		restore_wifi

		;;	
esac


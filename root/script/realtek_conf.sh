#!/bin/sh

PROJECT_TYPE=`cat /proc/device-tree/model`

get_techno() {
local flag=""
local STR=$1
local len=${#STR}

value=0
while [ $len -gt 0 ]; do
	len=$((len -1))
	flag=${STR:$len:1}
	case $flag in
		'b' )  ret_value=$((ret_value + 1))
		;;
		'g' )  ret_value=$((ret_value + 2)) 
		;;
		'a' )  ret_value=$((ret_value + 4))
		;;
		'n' )  ret_value=$((ret_value + 8)) 
		;;
		* )    echo $flag is not supported
	esac
done
#ntmore added only mode (Temporary)
if [ $STR = "g" ];then
	echo "1024" > $RTL_RATE
else
	echo "15" > $RTL_RATE
fi
}

#backup the conf file
local COUNTER=0
local ACCEPT_MAC_FILE="/etc/config/ath6k_conf/hostapd.accept"    
local DENY_MAC_FILE="/etc/config/ath6k_conf/hostapd.deny"
local ACCEPT_SECOND_MAC_FILE="/etc/config/ath6k_conf/hostapd_second.accept"
local DENY_SECOND_MAC_FILE="/etc/config/ath6k_conf/hostapd_second.deny"
local ACCEPT_FILE="/etc/config/wifi-accept"
local DENY_FILE="/etc/config/wifi-deny"
local ACCEPT_SECOND_FILE="/etc/config/wifi-second-accept"
local DENY_SECOND_FILE="/etc/config/wifi-second-deny"

SECOND_SSID_ENABLED=`uci get /etc/config/wifi-second.wifi_start.second_ssid_enabled`

let SSID_NO=0
let EXIT_LOOP=0
CONF_FILE_NAME='wifi'
HAPD_ACCEPT_FILE=$ACCEPT_MAC_FILE
HAPD_DENY_FILE=$DENY_MAC_FILE
ACCEPT_FILE_SRC=$ACCEPT_FILE
DENY_FILE_SRC=$DENY_FILE

while [ $EXIT_LOOP = 0 ]; do

    if [ $SSID_NO = 0 ]; then
	CONF_FILE_NAME='wifi'
	HAPD_ACCEPT_FILE=$ACCEPT_MAC_FILE
	HAPD_DENY_FILE=$DENY_MAC_FILE
	ACCEPT_FILE_SRC=$ACCEPT_FILE
	DENY_FILE_SRC=$DENY_FILE
	CONF_SSID="wlan0"
    else
	CONF_FILE_NAME='wifi-second'
	HAPD_ACCEPT_FILE=$ACCEPT_SECOND_MAC_FILE
	HAPD_DENY_FILE=$DENY_SECOND_MAC_FILE
	ACCEPT_FILE_SRC=$ACCEPT_SECOND_FILE
	DENY_FILE_SRC=$DENY_SECOND_FILE
	CONF_SSID="wlan0-va0"
    fi

# Realtek definitions
local RTL_PATH=/var/rtl8192c/$CONF_SSID
local RTL_SSID=$RTL_PATH/ssid
local RTL_TECHNO=$RTL_PATH/band
local RTL_RATE=$RTL_PATH/basic_rates
local RTL_ENCRYPT=$RTL_PATH/encrypt

# altair original [S]
#local RTL_WEPKEY_128_1=$RTL_PATH/wepkey1_128_hex
#local RTL_WEPKEY_128_2=$RTL_PATH/wepkey2_128_hex
#local RTL_WEPKEY_128_3=$RTL_PATH/wepkey3_128_hex
#local RTL_WEPKEY_128_4=$RTL_PATH/wepkey4_128_hex
#local RTL_WEPKEY_64_1=$RTL_PATH/wepkey1_64_hex
#local RTL_WEPKEY_64_2=$RTL_PATH/wepkey2_64_hex
#local RTL_WEPKEY_64_3=$RTL_PATH/wepkey3_64_hex
#local RTL_WEPKEY_64_4=$RTL_PATH/wepkey4_64_hex
# altair original [E]

local RTL_WEPKEY1=$RTL_PATH/wepkey1
local RTL_WEPKEY2=$RTL_PATH/wepkey2
local RTL_WEPKEY3=$RTL_PATH/wepkey3
local RTL_WEPKEY4=$RTL_PATH/wepkey4
local RTL_ENABLE_VAP=$RTL_PATH/vap_enable

local RTL_PASSPHRASE=$RTL_PATH/wpa_psk
local RTL_WSC_PSK=$RTL_PATH/wsc_psk
local RTL_ENABLE_1X=$RTL_PATH/enable_1x
local RTL_WPA_AUTH=$RTL_PATH/wpa_auth
local RTL_WPA_CIPHER=$RTL_PATH/wpa_cipher
local RTL_WPA2_CIPHER=$RTL_PATH/wpa2_cipher

local RTL_WEP=$RTL_PATH/wep
local RTL_WEP_DEFAULT_KEY=$RTL_PATH/wep_default_key
local RTL_WEP_KEY_TYPE=$RTL_PATH/wep_key_type
local RTL_AUTH_TYPE=$RTL_PATH/auth_type

local RTL_WSC_DISABLED=$RTL_PATH/wsc_disabled
local RTL_WSC_CONF=$RTL_PATH/wsc_configured
local RTL_WSC_AUTH=$RTL_PATH/wsc_auth
local RTL_WSC_ENC=$RTL_PATH/wsc_enc
local RTL_WSC_PIN=$RTL_PATH/wsc_pin #jkkim 0520
local RTL_WSC_CONFIGBYEXTREG=$RTL_PATH/wsc_configbyextreg

local RTL_WSC_MODE=$RTL_PATH/wsc_method

#ntmore added wmm mode (Temporary)
local RTL_WMM=$RTL_PATH/wmm_enabled
#ntmore added second antenna (on=2T2R, off=1T1R)
local RTL_SECOND_TR=$RTL_PATH/MIMO_TR_mode
#ntmore added max sta_num
local RTL_STA_NUM=supported_sta_num
local RTL_REG_DOMAIN=$RTL_PATH/reg_domain

    SSID=`uci get /etc/config/$CONF_FILE_NAME.wifi.ssid`
    TECHNOLOGY=`uci get /etc/config/$CONF_FILE_NAME.wifi.technology`
    ENCRIPTION=`uci get /etc/config/$CONF_FILE_NAME.wifi.sec_encryption`
    PAIRWISE=`uci get /etc/config/$CONF_FILE_NAME.wifi.sec_pairwise`

    PASSWORD=`uci get /etc/config/$CONF_FILE_NAME.wifi.sec_pass`
    IGNORE_BROADCAST_SSID=`uci get /etc/config/$CONF_FILE_NAME.wifi.ignore_broadcast_ssid`
    MACADDR_ACL_POLICY=`uci get /etc/config/$CONF_FILE_NAME.wifi.macaddr_acl`
    MAC_ADDR_ACCEPT_NUM=`uci get /etc/config/$CONF_FILE_NAME.wifi.accept_mac_num`
    MAC_ADDR_DENY_NUM=`uci get /etc/config/$CONF_FILE_NAME.wifi.deny_mac_num`
if [ $SSID_NO = 0 ]; then
    WMM_ENABLED=`uci get /etc/config/$CONF_FILE_NAME.wifi.wmm_enabled`
fi
    WEP_KEY0=`uci get /etc/config/$CONF_FILE_NAME.wifi.sec_wep_key0`
    WEP_KEY1=`uci get /etc/config/$CONF_FILE_NAME.wifi.sec_wep_key1`
    WEP_KEY2=`uci get /etc/config/$CONF_FILE_NAME.wifi.sec_wep_key2`
    WEP_KEY3=`uci get /etc/config/$CONF_FILE_NAME.wifi.sec_wep_key3`
    WEP_TYPE=`uci get /etc/config/$CONF_FILE_NAME.wifi.set_wep_type`
    WEP_DEFAULT_KEY=`uci get /etc/config/$CONF_FILE_NAME.wifi.sec_wep_default_key`
if [ $SSID_NO = 0 ]; then
    CHANNEL=`uci get /etc/config/$CONF_FILE_NAME.wifi.channel`
    CHANNEL_SELECT=`uci get /etc/config/$CONF_FILE_NAME.wifi.wifi_channel_select`
    WPS_ENABLED=`uci get /etc/config/$CONF_FILE_NAME.wifi.wps_enabled`
    WPS_MODE=`cat /var/rtl8192c/wlan0/wsc_method`

	if [ -z $WPS_MODE ]; then
	       WPS_MODE="2"
	fi

    WPS_ROUTER_PIN=`uci get /etc/config/$CONF_FILE_NAME.wifi.wps_router_pin`
    WIFI_MCAST_RATE=`uci get /etc/config/$CONF_FILE_NAME.wifi.mcast_rate`
    BANDWIDTH=`uci get /etc/config/$CONF_FILE_NAME.wifi.bandwidth`
fi
    NUM_STA=`uci get /etc/config/$CONF_FILE_NAME.wifi.num_sta`
    PRIVACY_SEPERATION=`uci get /etc/config/$CONF_FILE_NAME.wifi.privacy_seperator`
    BEACON_INTERVAL=`uci get /etc/config/$CONF_FILE_NAME.wifi.beacon_interval`
    REG_DOMAIN=`uci get /etc/config/$CONF_FILE_NAME.wifi.reg_domain`
#ntmore added second antenna (on=2T2R, off=1T1R)
    if [ $SSID_NO = 0 ]; then
        SECOND_TR=`uci get /etc/config/$CONF_FILE_NAME.wifi.second_tr` 
    fi
#ntmore added max client count (0 = device configured, )

	MAX_STA1=`uci get /etc/config/wifi.wifi.max_client_count`
	MAX_STA2=`uci get /etc/config/wifi-second.wifi.max_client_count`
	
    if [ $SECOND_SSID_ENABLED = "enable" ]; then
		if [ $MAX_STA1 = "0" ];then 
			MAX_STA1="5"
		else
			MAX_STA1=`uci get /etc/config/wifi.wifi.max_client_count`
		fi

		if [ $MAX_STA2 = "0" ];then 
			MAX_STA2="5"
		else
			MAX_STA2=`uci get /etc/config/wifi-second.wifi.max_client_count`
		fi
				
	elif [ $SECOND_SSID_ENABLED = "disable" ]; then
		if [ $MAX_STA1 = "0" ];then
			MAX_STA1="10"
		else
			MAX_STA1=`uci get /etc/config/wifi.wifi.max_client_count`
		fi

		if [ $MAX_STA2 = "0" ];then 
			MAX_STA2="5"
		else
			MAX_STA2=`uci get /etc/config/wifi-second.wifi.max_client_count`
		fi		
	fi	

			
#-------------------------------- first clean all
/root/script/default_setting.sh $CONF_SSID ap

#---------------------------- test setting for rate setting, twkim
  RATE_SETTING_CHECK=`uci get -q /etc/config/wifi.wifi.rate`;
if [ $RATE_SETTING_CHECK ];then
  echo 0 >/var/rtl8192c/wlan0/rate_adaptive_enabled
  if [ $RATE_SETTING_CHECK = "b_1" ];then
      fNb_rate_setting=1
      supported_rate_setting=1
      channel_bonding=0
  elif [ $RATE_SETTING_CHECK = "b_2" ]; then
      fNb_rate_setting=2
      supported_rate_setting=2
      channel_bonding=0
  elif [ $RATE_SETTING_CHECK = "b_4" ]; then
      fNb_rate_setting=4
      supported_rate_setting=4
      channel_bonding=0
  elif [ $RATE_SETTING_CHECK = "b_8" ]; then
      fNb_rate_setting=8
      supported_rate_setting=8
      channel_bonding=0
  elif [ $RATE_SETTING_CHECK = "g_1" ]; then
      fNb_rate_setting=16
      supported_rate_setting=16
      channel_bonding=0
  elif [ $RATE_SETTING_CHECK = "g_2" ]; then
      fNb_rate_setting=32
      supported_rate_setting=32
      channel_bonding=0
  elif [ $RATE_SETTING_CHECK = "g_4" ]; then
      fNb_rate_setting=64
      supported_rate_setting=64
      channel_bonding=0
  elif [ $RATE_SETTING_CHECK = "g_8" ]; then
      fNb_rate_setting=128
      supported_rate_setting=128
      channel_bonding=0
  elif [ $RATE_SETTING_CHECK = "g_16" ]; then
      fNb_rate_setting=256
      supported_rate_setting=256
      channel_bonding=0
  elif [ $RATE_SETTING_CHECK = "g_32" ]; then
      fNb_rate_setting=512
      supported_rate_setting=512
      channel_bonding=0
  elif [ $RATE_SETTING_CHECK = "g_64" ]; then
      fNb_rate_setting=1024
      supported_rate_setting=1024
      channel_bonding=0
  elif [ $RATE_SETTING_CHECK = "g_128" ]; then
      fNb_rate_setting=2048
      supported_rate_setting=2048
      channel_bonding=0
  elif [ $RATE_SETTING_CHECK = "n_1" ]; then
      fNb_rate_setting=4096
      supported_rate_setting=2048
      channel_bonding=1
  elif [ $RATE_SETTING_CHECK = "n_2" ]; then
      fNb_rate_setting=8192
      supported_rate_setting=2048
      channel_bonding=1
  elif [ $RATE_SETTING_CHECK = "n_4" ]; then
      fNb_rate_setting=16384
      supported_rate_setting=2048
      channel_bonding=1
  elif [ $RATE_SETTING_CHECK = "n_8" ]; then
      fNb_rate_setting=32768
      supported_rate_setting=2048
      channel_bonding=1
  elif [ $RATE_SETTING_CHECK = "n_16" ]; then
      fNb_rate_setting=65536
      supported_rate_setting=2048
      channel_bonding=1
  elif [ $RATE_SETTING_CHECK = "n_32" ]; then
      fNb_rate_setting=131072
      supported_rate_setting=2048
      channel_bonding=1
  elif [ $RATE_SETTING_CHECK = "n_64" ]; then
      fNb_rate_setting=262144
      supported_rate_setting=2048
      channel_bonding=1
  elif [ $RATE_SETTING_CHECK = "n_128" ]; then
      fNb_rate_setting=524288
      supported_rate_setting=2048
      channel_bonding=1
  else
      echo 1 >/var/rtl8192c/wlan0/rate_adaptive_enabled
      fNb_rate_setting=1
      supported_rate_setting=4095
      channel_bonding=0
  fi
  #move before value check line echo 0 >/var/rtl8192c/wlan0/rate_adaptive_enabled
  echo $fNb_rate_setting >/var/rtl8192c/wlan0/fix_rate
  echo $supported_rate_setting >/var/rtl8192c/wlan0/supported_rate
  echo $fNb_rate_setting >/var/rtl8192c/wlan0/basic_rates
  echo $channel_bonding_setting >/var/rtl8192c/wlan0/channel_bonding
fi #RATE_SETTING_CHECK

#-------------------------------- update db for web gui
#    db_writer -p probe1_update_trigger 1  #NTmore, no use 

#-------------------------------- Inserting SSID

    echo $SSID > $RTL_SSID

#-------------------------------- Change Reg_Domain
    echo $REG_DOMAIN > $RTL_REG_DOMAIN

#-------------------------------- Inserting channel first then figure out if either automatic/manual selection channel
if [ $SSID_NO = 0 ]; then
local RTL_CHANNEL=$RTL_PATH/channel

    if [ $CHANNEL_SELECT = "manual" ];then
	    echo $CHANNEL > $RTL_CHANNEL
    else
		if [ $PROJECT_TYPE == "NTLR-310" ];then
		ACS_RANDOM=`echo $((RANDOM % 2))` 
		case $ACS_RANDOM in 
					0)
						export CHANNEL=6 
					;;
					1) 
						export CHANNEL=11			
					;;
					*)
						export CHANNEL=11 
					;;		
		esac
		else #NTLR210/NTLD200
		ACS_RANDOM=`echo $((RANDOM % 3))` 
		case $ACS_RANDOM in 
					0)
						export CHANNEL=1 
					;;
					1) 
						export CHANNEL=6			
					;;
					2) 
						export CHANNEL=11			
					;;
					*)
						export CHANNEL=6
					;;		
		esac		
		fi 
		echo $CHANNEL > $RTL_CHANNEL
    fi
fi
#-------------------------------- Inserting privacy seperation
local RTL_PRIVACY_SEPERATION=$RTL_PATH/block_relay

    if [ $PRIVACY_SEPERATION = "enable" ]; then
    	echo 1 > $RTL_PRIVACY_SEPERATION
    else
	echo 0 > $RTL_PRIVACY_SEPERATION
    fi


#-------------------------------- Inserting supported sta num
local RTL_NUM_STA=$RTL_PATH/supported_sta_num

    echo $NUM_STA > $RTL_NUM_STA

#-------------------------------- Inserting beacon interval
if [ $SSID_NO = 0 ]; then
local RTL_BEACON_INTERVAL=$RTL_PATH/beacon_interval

    echo $BEACON_INTERVAL > $RTL_BEACON_INTERVAL
fi
#-------------------------------- Do we want to generate SSID broadcast ?
local RTL_HIDDEN_SSID=$RTL_PATH/hidden_ssid
	if [ $IGNORE_BROADCAST_SSID = 0 ] ; then
		echo 0 > $RTL_HIDDEN_SSID
	else
		echo 1 > $RTL_HIDDEN_SSID
	fi
#-------------------------------- handle channel bonding (20/40 MHz and coexistance
# channel_bonding: BW: 0 - 20M mode, 1 - 40M, 2 - 80M mode
if [ $SSID_NO = 0 ]; then
	local RTL_CHANNEL_BONDING=$RTL_PATH/channel_bonding
	local RTL_COEXIST=$RTL_PATH/coexist_enabled
	    if [ $BANDWIDTH = "40MHz" ]; then 
	        echo "1" > $RTL_CHANNEL_BONDING
	        echo "0" > $RTL_COEXIST
	    else 
	        if [ $BANDWIDTH = "20MHz" ]; then 
	            echo "0" > $RTL_CHANNEL_BONDING
	            echo "0" > $RTL_COEXIST
	        else 
	            if [ $BANDWIDTH = "20-40-coexist" ]; then 
	                echo "1" > $RTL_CHANNEL_BONDING
	                echo "1" > $RTL_COEXIST
	            fi
	        fi
	    fi
fi
#-------------------------------- ACL (Mac filtering) implementation based on Atheros model
#-------------------------------- If selected, 2 compatible files are used for accepted & denied
local RTL_ACLMODE=$RTL_PATH/macac_enabled
local RTL_ACLNUM=$RTL_PATH/macac_num

#test ACL policy - 0- allow all , 1 - allow only what is in list , 2 - deny only what is in list
        echo $MACADDR_ACL_POLICY > $RTL_ACLMODE
        echo 0  > $RTL_ACLNUM

if [ $MACADDR_ACL_POLICY = 1 ]; then
        let COUNTER=0
        let ACLCOUNTER=0
        while [  $COUNTER -lt  $MAC_ADDR_ACCEPT_NUM ]; do
        ACCEPT_EN=`uci get $ACCEPT_FILE_SRC.@access_accept[$COUNTER].enable`
        if [ $ACCEPT_EN == "enable" ];then 
	                MACADD=`uci get $ACCEPT_FILE_SRC.@access_accept[$COUNTER].accept_mac | sed 's/://g'`
                    let ACLCOUNTER=ACLCOUNTER+1
                	RTL_ACLADDR=$RTL_PATH/macac_addr$ACLCOUNTER
	                echo $MACADD > $RTL_ACLADDR
        	        echo $ACLCOUNTER  > $RTL_ACLNUM
		fi
        let COUNTER=COUNTER+1
        done
fi


if [ $MACADDR_ACL_POLICY = 2 ]; then
        let COUNTER=0
        let ACLCOUNTER=0
        while [  $COUNTER -lt  $MAC_ADDR_DENY_NUM ]; do
		DENY_EN=`uci get $DENY_FILE_SRC.@access_deny[$COUNTER].enable` #for new macfilter version
	    	if [ $DENY_EN == "enable" ];then 
	                MACADD=`uci get $DENY_FILE_SRC.@access_deny[$COUNTER].deny_mac | sed 's/://g'`
        	        let ACLCOUNTER=ACLCOUNTER+1
                	RTL_ACLADDR=$RTL_PATH/macac_addr$ACLCOUNTER
	                echo $MACADD > $RTL_ACLADDR
        	        echo $ACLCOUNTER  > $RTL_ACLNUM
		fi
       	let COUNTER=COUNTER+1
        done
fi

#-------------------------------- TX POWER
if [ $SSID_NO = 0 ]; then
	TXPOWER=`uci get /etc/config/$CONF_FILE_NAME.wifi.tx_power`
fi

echo "TX POWER="$TXPOWER
if [ $TXPOWER == "high" ]; then
    echo "setting $SSID_NO TXPOWER to HIGH"
	if [ $SSID_NO = 0 ]; then
	    iwpriv wlan0 set_mib powerpercent=100
	fi
else
    if [ $TXPOWER == "medium" ]; then
       echo "setting $SSID_NO TXPOWER to MEDIUM"
	if [ $SSID_NO = 0 ]; then
	    iwpriv wlan0 set_mib powerpercent=10
	fi
    else
       if [ $TXPOWER == "low" ]; then
          echo "setting $SSID_NO TXPOWER to LOW"
	if [ $SSID_NO = 0 ]; then
	    iwpriv wlan0 set_mib powerpercent=1
	fi

       fi
    fi
fi
#------------------ WPS ENABLED    
	if [ $SSID_NO = 0 ]; then
	    if [ $WPS_ENABLED = "enable" ]; then
	        echo 0 > $RTL_WSC_DISABLED
	    else
	        echo 1 > $RTL_WSC_DISABLED
	    fi
            echo $WPS_ROUTER_PIN > $RTL_WSC_PIN # jkkim 0520
	fi

#------------------- WPS MODE SETTING
	if [ $SSID_NO = 0 ]; then
            if [ $WPS_ENABLED = "enable" ]; then
              if [ $ENCRIPTION != "wep" ]; then
                if [ $ENCRIPTION != "wpa" ]; then
                  echo $WPS_MODE > $RTL_WSC_MODE
                fi
              fi
            fi
	fi

#-------------------------------- Clearly which bands are supported like b,g,n
    get_techno $TECHNOLOGY
    echo $ret_value > $RTL_TECHNO

#-------------------------------- WMM configuration, ntmore added only mode (Temporary)
	if [ $SSID_NO = 0 ]; then
		if [ $WMM_ENABLED = "enable" ]; then
			echo 1 > $RTL_WMM
		else
			echo 0 > $RTL_WMM
		fi
	fi

#-------------------------------- MIMO mode assignment configuration, ntmore added (Temporary)
    if [ $SSID_NO = 0 ]; then
        if [ $SECOND_TR = "enable" ]; then
                echo 3 > $RTL_SECOND_TR #2T2R
	elif [ $SECOND_TR = "disable" ];then
		echo 4 > $RTL_SECOND_TR #1T1R
        else
                echo 4 > $RTL_SECOND_TR
        fi
    fi

#-------------------------------- MAX sta number, ntmore added (Temporary)       
    if [ $SECOND_SSID_ENABLED = "enable" ];then

	echo $MAX_STA1 > /var/rtl8192c/wlan0/$RTL_STA_NUM
	echo $MAX_STA2 > /var/rtl8192c/wlan0-va0/$RTL_STA_NUM

    elif [ $SECOND_SSID_ENABLED = "disable" ];then

		if [ $SSID_NO = 0 ]; then
			echo $MAX_STA1 > /var/rtl8192c/wlan0/$RTL_STA_NUM
			echo $MAX_STA2 > /var/rtl8192c/wlan0-va0/$RTL_STA_NUM
		fi
	fi
#--------------------------------  Encryption mode handling for wep,wpa,wpa2, mixed wpa/wpa2 and none

    if [ $ENCRIPTION = "none" ]; then	
        echo "2" > $RTL_AUTH_TYPE
        echo "0" > $RTL_ENCRYPT
        echo "0" > $RTL_ENABLE_1X
        echo "0" > $RTL_WPA_AUTH
        echo "0" > $RTL_WPA_CIPHER
    else
# altair original [S]
#    else
#        if [ $ENCRIPTION = "wep" ]; then
#            if [ `echo $WEP_KEY0 | wc -c` -gt 11 ]; then
#                echo "WiFi Setting: 128 bit wep"
#                echo $WEP_KEY0 > $RTL_WEPKEY_128_1
#                echo $WEP_KEY1 > $RTL_WEPKEY_128_2
#                echo $WEP_KEY2 > $RTL_WEPKEY_128_3
#                echo $WEP_KEY3 > $RTL_WEPKEY_128_4
#                /root/script/wep-128-hex.sh $CONF_SSID ap
#             else
#                echo "WiFi Setting: 64 bit wep"
#                echo $WEP_KEY0 > $RTL_WEPKEY_64_1
#                echo $WEP_KEY1 > $RTL_WEPKEY_64_2
#                echo $WEP_KEY2 > $RTL_WEPKEY_64_3
#                echo $WEP_KEY3 > $RTL_WEPKEY_64_4
#                /root/script/wep-64-hex.sh $CONF_SSID ap
#             fi
# altair original [E]
        if [ $ENCRIPTION = "wep" ]; then	
            echo $WEP_KEY0 > $RTL_WEPKEY1
            echo $WEP_KEY1 > $RTL_WEPKEY2
            echo $WEP_KEY2 > $RTL_WEPKEY3
            echo $WEP_KEY3 > $RTL_WEPKEY4

            if [ $WEP_DEFAULT_KEY = "0" ]; then
			  CURRENT_KEY=$WEP_KEY0	#jwpark 2015.03.23 modified in order to process kind of wepkey at wifi script.
			  KEY_FILE_NUM=wepkey1_
              echo '0'>$RTL_WEP_DEFAULT_KEY
            elif [ $WEP_DEFAULT_KEY = "1" ]; then
			  CURRENT_KEY=$WEP_KEY1
			  KEY_FILE_NUM=wepkey2_
              echo '1'>/var/rtl8192c/wlan0/wep_default_key
            elif [ $WEP_DEFAULT_KEY = "2" ]; then
			  CURRENT_KEY=$WEP_KEY2
			  KEY_FILE_NUM=wepkey3_
              echo '2'>$RTL_WEP_DEFAULT_KEY
			elif [ $WEP_DEFAULT_KEY = "3" ]; then
			  CURRENT_KEY=$WEP_KEY3
			  KEY_FILE_NUM=wepkey4_
              echo '3'>$RTL_WEP_DEFAULT_KEY
            fi
            
#			echo "======= $CURRENT_KEY ========"
#			echo "======= $RTL_PATH/$KEY_FILE_NUM$WEP_TYPE ========"

	    if [ $WEP_TYPE = "64_asc" ]; then
                  echo -n $CURRENT_KEY | od -A n -t x1 | sed 's/ //g' > $RTL_PATH/$KEY_FILE_NUM$WEP_TYPE
        	  /root/script/wep-64-asc.sh $CONF_SSID ap 
            elif [ $WEP_TYPE = "64_hex" ]; then
                  echo $CURRENT_KEY > $RTL_PATH/$KEY_FILE_NUM$WEP_TYPE
        	  /root/script/wep-64-hex.sh $CONF_SSID ap 
            elif [ $WEP_TYPE = "128_asc" ]; then
                  echo -n $CURRENT_KEY | od -A n -t x1 | sed 's/ //g' > $RTL_PATH/$KEY_FILE_NUM$WEP_TYPE
        	  /root/script/wep-128-asc.sh $CONF_SSID ap 
            elif [ $WEP_TYPE = "128_hex" ]; then
                  echo $CURRENT_KEY > $RTL_PATH/$KEY_FILE_NUM$WEP_TYPE
        	  /root/script/wep-128-hex.sh $CONF_SSID ap 
            fi
        else
           if [ $ENCRIPTION = "wpa" ]; then
                echo $PASSWORD > $RTL_PASSPHRASE   
    	        echo "87654321" > $RTL_WSC_PSK
                if [ $PAIRWISE = "TKIP" ] ; then
                        /root/script/wpa-tkip.sh $CONF_SSID ap
                else
                        /root/script/wpa-aes.sh $CONF_SSID ap
                fi
            else
                if [ $ENCRIPTION = "wpa2" ]; then    
					echo $PASSWORD > $RTL_PASSPHRASE 
					echo "87654321" > $RTL_WSC_PSK
                    if [ $PAIRWISE = "CCMP" ] ; then
                            /root/script/wpa2-aes.sh $CONF_SSID ap
                    else
                            /root/script/wpa2-tkip.sh $CONF_SSID ap
                    fi
                else
                    if [ $ENCRIPTION = "mixed-wpa-wpa2" ]; then
                        echo $PASSWORD > $RTL_PASSPHRASE 
	                    echo "87654321" > $RTL_WSC_PSK
                        if [ $PAIRWISE = "CCMP" ]; then
                                /root/script/wpa-wpa2-mix-aes.sh $CONF_SSID ap
    
                        elif [ $PAIRWISE = "TKIP-CCMP" ];then
                                /root/script/wpa-wpa2-mix-auto.sh $CONF_SSID ap
                        else
                                /root/script/wpa-wpa2-mix-tkip.sh $CONF_SSID ap
                        fi                               
                    fi
                fi
            fi
        fi
    fi

    if [ $SECOND_SSID_ENABLED = "disable" ]; then
	let EXIT_LOOP=1
    fi

    let SSID_NO=SSID_NO+1

    if [ $SSID_NO = 2 ];then
        let EXIT_LOOP=1
    fi

done	


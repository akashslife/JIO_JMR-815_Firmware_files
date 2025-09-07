#!/bin/bash
#
# script file to start WLAN
#
if [ $# -lt 3 ]; then echo "Usage: $0 wlan root type";  exit 1 ; fi

#echo "my: [$1] [$2] [$3]"

CONFIG_ROOT_DIR="/var/rtl8192c"
CONFIG_DIR=$CONFIG_ROOT_DIR/$1

if [ -z "$SCRIPT_DIR" ]; then
	SCRIPT_DIR=`cat $CONFIG_ROOT_DIR/wifi_script_dir`
fi
START_WLAN_APP=$SCRIPT_DIR/wlanapp_8192c.sh

#if [ -z "$ROOT_WLAN" ]; then
#	ROOT_WLAN=`echo $1 | cut -b -5`
#fi

OP_INTF=$1
ROOT_WLAN=$2
EXT=$3

ROOT_CONFIG_DIR=$CONFIG_ROOT_DIR/$ROOT_WLAN

SET_WLAN="iwpriv $1"
SET_WLAN_PARAM="$SET_WLAN set_mib"
IFCONFIG=ifconfig

## Disable WLAN MAC driver and shutdown interface first ##
$IFCONFIG $OP_INTF down

GET_VALUE=
GET_VALUE_TMP=
GET_VALUE_WLAN_DISABLED=`cat $CONFIG_DIR/wlan_disabled`
GET_VALUE_WLAN_MODE=`cat $CONFIG_DIR/wlan_mode`

##$SET_WLAN set_mib vap_enable=0

## kill wlan application daemon ##

##$START_WLAN_APP kill $1

## Set parameters to driver ##

GET_VALUE=`cat $ROOT_CONFIG_DIR/reg_domain`
$SET_WLAN set_mib regdomain=$GET_VALUE

#EXT=`echo $1 | cut -b 7-8`
NUM=0
if [ "$EXT" = "va" ] ; then
	NUM=${1#w*va};
	NUM=$((NUM +1))
#	NUM=`echo $1 | cut -b 9`
#	NUM=`expr $NUM + 1`
fi

GET_VALUE=`cat $ROOT_CONFIG_DIR/wlan${NUM}_addr`
$IFCONFIG $OP_INTF hw ether $GET_VALUE

IS_ROOT_WLAN=0;
if [ "$EXT" = "root" ] ; then
	IS_ROOT_WLAN=1;
fi

if [ "$GET_VALUE_WLAN_MODE" = '1' ]; then
	## client mode
	GET_VALUE=`cat $CONFIG_DIR/network_type`
	if  [ "$GET_VALUE" = '0' ]; then
		$SET_WLAN set_mib opmode=8
	else
		$SET_WLAN set_mib opmode=32
		GET_VALUE_TMP=`cat $CONFIG_DIR/default_ssid`
		$SET_WLAN set_mib defssid="$GET_VALUE_TMP"
	fi
else
	## AP mode
	$SET_WLAN set_mib opmode=16
fi
##$IFCONFIG $OP_INTF hw ether $WLAN_MAC_ADDR

##if [ "$GET_VALUE_WLAN_MODE" = '2' ]; then
##		$SET_WLAN set_mib wds_pure=1
##else
##		$SET_WLAN set_mib wds_pure=0
##fi

# set RF parameters
if [ $IS_ROOT_WLAN = 1 ]; then
	GET_VALUE=`cat $CONFIG_DIR/channel`
	$SET_WLAN set_mib channel=$GET_VALUE

	GET_VALUE=`cat $CONFIG_DIR/ch_hi`
	$SET_WLAN set_mib ch_hi=$GET_VALUE

	GET_VALUE=`cat $CONFIG_DIR/ch_low`
	$SET_WLAN set_mib ch_low=$GET_VALUE
	
	GET_VALUE=`cat $CONFIG_DIR/led_type`
	$SET_WLAN set_mib led_type=$GET_VALUE
	
	GET_VALUE=`cat $CONFIG_DIR/MIMO_TR_mode`
	$SET_WLAN set_mib MIMO_TR_mode=$GET_VALUE
	
	GET_TX_POWER_CCK_A=`cat $CONFIG_DIR/tx_power_cck_a`
	GET_TX_POWER_CCK_B=`cat $CONFIG_DIR/tx_power_cck_b`
	GET_TX_POWER_HT40_1S_A=`cat $CONFIG_DIR/tx_power_ht40_1s_a`
	GET_TX_POWER_HT40_1S_B=`cat $CONFIG_DIR/tx_power_ht40_1s_b`

	GET_TX_POWER_DIFF_HT40_2S=`cat $CONFIG_DIR/tx_power_diff_ht40_2s`
	GET_TX_POWER_DIFF_HT20=`cat $CONFIG_DIR/tx_power_diff_ht20`
	GET_TX_POWER_DIFF_OFDM=`cat $CONFIG_DIR/tx_power_diff_ofdm`

	$SET_WLAN set_mib pwrlevelCCK_A=$GET_TX_POWER_CCK_A
	$SET_WLAN set_mib pwrlevelCCK_B=$GET_TX_POWER_CCK_B
	$SET_WLAN set_mib pwrlevelHT40_1S_A=$GET_TX_POWER_HT40_1S_A
	$SET_WLAN set_mib pwrlevelHT40_1S_B=$GET_TX_POWER_HT40_1S_B
	$SET_WLAN set_mib pwrdiffHT40_2S=$GET_TX_POWER_DIFF_HT40_2S
	$SET_WLAN set_mib pwrdiffHT20=$GET_TX_POWER_DIFF_HT20
	$SET_WLAN set_mib pwrdiffOFDM=$GET_TX_POWER_DIFF_OFDM
	
	GET_11N_TSSI1=`cat $CONFIG_DIR/tssi_1`
	$SET_WLAN set_mib tssi1=$GET_11N_TSSI1
	GET_11N_TSSI2=`cat $CONFIG_DIR/tssi_2`
	$SET_WLAN set_mib tssi2=$GET_11N_TSSI2
	
	GET_VALUE=`cat $CONFIG_DIR/11n_ther`
	$SET_WLAN set_mib ther=$GET_VALUE
	
	GET_VALUE=`cat $CONFIG_DIR/trswitch`
	$SET_WLAN set_mib trswitch=$GET_VALUE

	GET_VALUE=`cat $CONFIG_DIR/11n_xcap`
	$SET_WLAN set_mib xcap=$GET_VALUE

	GET_VALUE=`cat $ROOT_CONFIG_DIR/beacon_interval`
	$SET_WLAN set_mib bcnint=$GET_VALUE

	GET_VALUE=`cat $CONFIG_DIR/dtim_period`
	$SET_WLAN set_mib dtimperiod=$GET_VALUE
fi # [ $IS_ROOT_WLAN = 1 ]

GET_VALUE=`cat $CONFIG_DIR/basic_rates`
$SET_WLAN set_mib basicrates=$GET_VALUE

GET_VALUE=`cat $CONFIG_DIR/supported_rate`
$SET_WLAN set_mib oprates=$GET_VALUE

GET_RATE_ADAPTIVE_VALUE=`cat $CONFIG_DIR/rate_adaptive_enabled`
if [ "$GET_RATE_ADAPTIVE_VALUE" = '0' ]; then
	$SET_WLAN set_mib autorate=0
	GET_FIX_RATE_VALUE=`cat $CONFIG_DIR/fix_rate`
	$SET_WLAN set_mib fixrate=$GET_FIX_RATE_VALUE
else
	$SET_WLAN set_mib autorate=1
fi

GET_VALUE=`cat $CONFIG_DIR/rts_threshold`
$SET_WLAN set_mib rtsthres=$GET_VALUE

GET_VALUE=`cat $CONFIG_DIR/frag_threshold`
$SET_WLAN set_mib fragthres=$GET_VALUE

GET_VALUE=`cat $CONFIG_DIR/inactivity_time`
$SET_WLAN set_mib expired_time=$GET_VALUE

GET_VALUE=`cat $CONFIG_DIR/preamble_type`
$SET_WLAN set_mib preamble=$GET_VALUE


GET_VALUE=`cat $CONFIG_DIR/hidden_ssid`
$SET_WLAN set_mib hiddenAP=$GET_VALUE


if [ "$OP_INTF" = "$ROOT_WLAN-vxd" ]; then
	GET_VALUE=`cat $CONFIG_ROOT_DIR/repeater_ssid`
else
	GET_VALUE=`cat $CONFIG_DIR/ssid`
fi
$SET_WLAN set_mib ssid=$GET_VALUE

GET_VALUE=`cat $CONFIG_DIR/macac_enabled`
$SET_WLAN set_mib aclmode=$GET_VALUE
$SET_WLAN set_mib aclnum=0

ACL_NUM=`cat $CONFIG_DIR/macac_num`
ITEM="1 2 3 4 5 6 7 8 9 10"
#for (( i=1; i<=$ACL_NUM; i=i+1 ))
if [ "0" != "$ACL_NUM" ]; then
   for i in $ITEM
   do	
	#echo "acl $i"
	GET_VALUE=`cat $CONFIG_DIR/macac_addr$i`
	$SET_WLAN set_mib acladdr=$GET_VALUE
	if [ "$i" = "$ACL_NUM" ]; then
	    break;
	fi
   done
fi

GET_WLAN_AUTH_TYPE=`cat $CONFIG_DIR/auth_type`
AUTH_TYPE=$GET_WLAN_AUTH_TYPE
GET_WLAN_ENCRYPT=`cat $CONFIG_DIR/encrypt`
if [ "$GET_WLAN_AUTH_TYPE" = "1" ] && [ "$GET_WLAN_ENCRYPT" != "1" ]; then
	# shared-key and not WEP enabled, force to open-system
	AUTH_TYPE=0
fi
$SET_WLAN set_mib authtype=$AUTH_TYPE

if [ "$GET_WLAN_ENCRYPT" = "0" ]; then
	$SET_WLAN set_mib encmode=0
elif [ "$GET_WLAN_ENCRYPT" = "1" ]; then
	### WEP mode ##
	GET_WEP=`cat $CONFIG_DIR/wep`
	GET_WEP_KEY_TYPE=`cat $CONFIG_DIR/wep_key_type`
	GET_WEP_KEY_ID=`cat $CONFIG_DIR/wep_default_key`
	if [ "$GET_WEP" = "1" ]; then
		if [ "$GET_WEP_KEY_TYPE" = "0" ]; then
			GET_WEP_KEY_1=`cat $CONFIG_DIR/wepkey1_64_asc`
			GET_WEP_KEY_2=`cat $CONFIG_DIR/wepkey2_64_asc`
			GET_WEP_KEY_3=`cat $CONFIG_DIR/wepkey3_64_asc`
			GET_WEP_KEY_4=`cat $CONFIG_DIR/wepkey4_64_asc`
		else
			GET_WEP_KEY_1=`cat $CONFIG_DIR/wepkey1_64_hex`
			GET_WEP_KEY_2=`cat $CONFIG_DIR/wepkey2_64_hex`
			GET_WEP_KEY_3=`cat $CONFIG_DIR/wepkey3_64_hex`
			GET_WEP_KEY_4=`cat $CONFIG_DIR/wepkey4_64_hex`
		fi
		
		$SET_WLAN set_mib encmode=1
		$SET_WLAN set_mib wepkey1=$GET_WEP_KEY_1
		$SET_WLAN set_mib wepkey2=$GET_WEP_KEY_2
		$SET_WLAN set_mib wepkey3=$GET_WEP_KEY_3
		$SET_WLAN set_mib wepkey4=$GET_WEP_KEY_4
		$SET_WLAN set_mib wepdkeyid=$GET_WEP_KEY_ID
	else
		if [ "$GET_WEP_KEY_TYPE" = "0" ]; then
			GET_WEP_KEY_1=`cat $CONFIG_DIR/wepkey1_128_asc`
			GET_WEP_KEY_2=`cat $CONFIG_DIR/wepkey2_128_asc`
			GET_WEP_KEY_3=`cat $CONFIG_DIR/wepkey3_128_asc`
			GET_WEP_KEY_4=`cat $CONFIG_DIR/wepkey4_128_asc`
		else
			GET_WEP_KEY_1=`cat $CONFIG_DIR/wepkey1_128_hex`
			GET_WEP_KEY_2=`cat $CONFIG_DIR/wepkey2_128_hex`
			GET_WEP_KEY_3=`cat $CONFIG_DIR/wepkey3_128_hex`
			GET_WEP_KEY_4=`cat $CONFIG_DIR/wepkey4_128_hex`
		fi
		$SET_WLAN set_mib encmode=5
		$SET_WLAN set_mib wepkey1=$GET_WEP_KEY_1
		$SET_WLAN set_mib wepkey2=$GET_WEP_KEY_2
		$SET_WLAN set_mib wepkey3=$GET_WEP_KEY_3
		$SET_WLAN set_mib wepkey4=$GET_WEP_KEY_4
		$SET_WLAN set_mib wepdkeyid=$GET_WEP_KEY_ID
	fi
else
        ## WPA mode ##
	$SET_WLAN set_mib encmode=2
fi
##$SET_WLAN set_mib wds_enable=0
##$SET_WLAN set_mib wds_encrypt=0

## Set 802.1x flag ##
_ENABLE_1X=0
if [ $GET_WLAN_ENCRYPT -lt 2 ]; then
	GET_ENABLE_1X=`cat $CONFIG_DIR/enable_1x`
	GET_MAC_AUTH_ENABLED=`cat $CONFIG_DIR/mac_auth_enabled`
	if [ "$GET_ENABLE_1X" != 0 ] || [ "$GET_MAC_AUTH_ENABLED" != 0 ]; then
		_ENABLE_1X=1
	fi
else
	_ENABLE_1X=1
fi
$SET_WLAN set_mib 802_1x=$_ENABLE_1X


#set band
GET_BAND=`cat $ROOT_CONFIG_DIR/band`
GET_WIFI_SPECIFIC=`cat $ROOT_CONFIG_DIR/wifi_specific`
if [ "$GET_VALUE_WLAN_MODE" != '1' ] && [ "$GET_WIFI_SPECIFIC" = 1 ] &&  [ "$GET_BAND" = '2' ] ; then
	GET_BAND=3
fi
if [ "$GET_BAND" = '8' ]; then
	GET_BAND=11
	$SET_WLAN set_mib deny_legacy=3
elif [ "$GET_BAND" = '2' ]; then
	GET_BAND=3
	$SET_WLAN set_mib deny_legacy=1
elif [ "$GET_BAND" = '10' ]; then
	GET_BAND=11
	$SET_WLAN set_mib deny_legacy=1
else
	$SET_WLAN set_mib deny_legacy=0
fi
$SET_WLAN set_mib band=$GET_BAND

###Set 11n parameter
if [ $IS_ROOT_WLAN = 1 ]; then
if [ $GET_BAND = 10 ] || [ $GET_BAND = 11 ]; then
	GET_CHANNEL_BONDING=`cat $CONFIG_DIR/channel_bonding`
	$SET_WLAN set_mib use40M=$GET_CHANNEL_BONDING

	GET_CONTROL_SIDEBAND=`cat $CONFIG_DIR/control_sideband`

	if [ "$GET_CHANNEL_BONDING" = 0 ]; then
	$SET_WLAN set_mib 2ndchoffset=0
	else
		if [ "$GET_CONTROL_SIDEBAND" = 0 ]; then
			 $SET_WLAN set_mib 2ndchoffset=1
		fi
		if [ "$GET_CONTROL_SIDEBAND" = 1 ]; then
			 $SET_WLAN set_mib 2ndchoffset=2
		fi
	fi

	GET_SHORT_GI=`cat $CONFIG_DIR/short_gi`
	$SET_WLAN set_mib shortGI20M=$GET_SHORT_GI
	$SET_WLAN set_mib shortGI40M=$GET_SHORT_GI

	GET_AGGREGATION=`cat $CONFIG_DIR/aggregation`

	if [ "$GET_AGGREGATION" = 0 ]; then
		$SET_WLAN set_mib ampdu=$GET_AGGREGATION
		$SET_WLAN set_mib amsdu=$GET_AGGREGATION
	elif [ "$GET_AGGREGATION" = 1 ]; then
		$SET_WLAN set_mib ampdu=1
		$SET_WLAN set_mib amsdu=0
	elif [ "$GET_AGGREGATION" = 2 ]; then
		$SET_WLAN set_mib ampdu=0
		$SET_WLAN set_mib amsdu=1
	elif [ "$GET_AGGREGATION" = 3 ]; then
		$SET_WLAN set_mib ampdu=1
		$SET_WLAN set_mib amsdu=1
	fi

	GET_STBC_ENABLED=`cat $CONFIG_DIR/stbc_enabled`
	$SET_WLAN set_mib stbc=$GET_STBC_ENABLED
	GET_COEXIST_ENABLED=`cat $CONFIG_DIR/coexist_enabled`
	$SET_WLAN set_mib coexist=$GET_COEXIST_ENABLED
fi # [ $GET_BAND = 10 ] || [ $GET_BAND = 11 ]
fi # [ $IS_ROOT_WLAN = 1 ]
##########

#set nat2.5 disable when client and mac clone is set
GET_MACCLONE_ENABLED=`cat $CONFIG_DIR/macclone_enable`
if [ "$GET_MACCLONE_ENABLED" = '1' -a "$GET_VALUE_WLAN_MODE" = '1' ]; then
	$SET_WLAN set_mib nat25_disable=1
	$SET_WLAN set_mib macclone_enable=1
else
	$SET_WLAN set_mib nat25_disable=0
	$SET_WLAN set_mib macclone_enable=0
fi

# set 11g protection mode
GET_PROTECTION_DISABLED=`cat $CONFIG_DIR/protection_disabled`
if  [ "$GET_PROTECTION_DISABLED" = '1' ] ;then
	$SET_WLAN set_mib disable_protection=1
else
	$SET_WLAN set_mib disable_protection=0
fi

# set block relay
GET_BLOCK_RELAY=`cat $CONFIG_DIR/block_relay`
$SET_WLAN set_mib block_relay=$GET_BLOCK_RELAY

# set WiFi specific mode
GET_WIFI_SPECIFIC=`cat $ROOT_CONFIG_DIR/wifi_specific`
$SET_WLAN set_mib wifi_specific=$GET_WIFI_SPECIFIC

# for WMM
GET_WMM_ENABLED=`cat $CONFIG_DIR/wmm_enabled`
$SET_WLAN set_mib qos_enable=$GET_WMM_ENABLED

# for guest access
GET_ACCESS=`cat $CONFIG_DIR/guest_access`
$SET_WLAN set_mib guest_access=$GET_ACCESS


#
# following settings is used when driver WPA module is included
#

GET_WPA_AUTH=`cat $CONFIG_DIR/wpa_auth`
#if [ $GET_VALUE_WLAN_MODE != 1 ] && [ $GET_WLAN_ENCRYPT -ge 2 ]  && [ $GET_WLAN_ENCRYPT -lt 7 ] && [ $GET_WPA_AUTH = 2 ]; then
if [ $GET_WLAN_ENCRYPT -ge 2 ]  && [ $GET_WLAN_ENCRYPT -lt 7 ] && [ $GET_WPA_AUTH = 2 ]; then
	if [ $GET_WLAN_ENCRYPT = 2 ]; then
		ENABLE=1
	elif [ $GET_WLAN_ENCRYPT = 4 ]; then
		ENABLE=2
	elif [ $GET_WLAN_ENCRYPT = 6 ]; then
		ENABLE=3
	else
		echo "invalid ENCRYPT value!"; exit
	fi
	$SET_WLAN set_mib psk_enable=$ENABLE

	if [ $GET_WLAN_ENCRYPT = 2 ] || [ $GET_WLAN_ENCRYPT = 6 ]; then
		GET_WPA_CIPHER_SUITE=`cat $CONFIG_DIR/wpa_cipher`
		if [ $GET_WPA_CIPHER_SUITE = 1 ]; then
			CIPHER=2
		elif [ $GET_WPA_CIPHER_SUITE = 2 ]; then
			CIPHER=8
		elif [ $GET_WPA_CIPHER_SUITE = 3 ]; then
			CIPHER=10
		else
			echo "invalid WPA_CIPHER_SUITE value!"; exit 1
		fi
	fi
	$SET_WLAN set_mib wpa_cipher=$CIPHER

	if [ $GET_WLAN_ENCRYPT = 4 ] || [ $GET_WLAN_ENCRYPT = 6 ]; then
		GET_WPA2_CIPHER_SUITE=`cat $CONFIG_DIR/wpa2_cipher`
		if [ $GET_WPA2_CIPHER_SUITE = 1 ]; then
			CIPHER=2
		elif [ $GET_WPA2_CIPHER_SUITE = 2 ]; then
			CIPHER=8
		elif [ $GET_WPA2_CIPHER_SUITE = 3 ]; then
			CIPHER=10
		else
			echo "invalid WPA2_CIPHER_SUITE value!"; exit 1
		fi
	fi
	$SET_WLAN set_mib wpa2_cipher=$CIPHER

	GET_WPA_PSK=`cat $CONFIG_DIR/wpa_psk`
	$SET_WLAN set_mib passphrase=$GET_WPA_PSK

	
	GET_WPA_GROUP_REKEY_TIME=`cat $CONFIG_DIR/gk_rekey`
	$SET_WLAN set_mib gk_rekey=$GET_WPA_GROUP_REKEY_TIME
else
	$SET_WLAN set_mib psk_enable=0
fi

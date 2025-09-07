#!/bin/sh

if [ $# -lt 2 ]; then echo "Usage: $0 iface op_mode";  exit 1 ; fi

CONFIG_ROOT_DIR="/var/rtl8192c"
CONFIG_DIR=$CONFIG_ROOT_DIR/$1

if [ -z "$SCRIPT_DIR" ]; then
        SCRIPT_DIR=`cat $CONFIG_ROOT_DIR/wifi_script_dir`
fi

#$SCRIPT_DIR/default_setting.sh $1

if [ $2 = 'ap' ]; then
	echo "0" > $CONFIG_DIR/wlan_mode
elif [ $2 = 'client' ]; then
	echo "1" > $CONFIG_DIR/wlan_mode
fi

echo "1" > $CONFIG_DIR/encrypt
echo "2" > $CONFIG_DIR/wep
#echo "0" > $CONFIG_DIR/wep_default_key
echo "0" > $CONFIG_DIR/wep_key_type
echo "2" > $CONFIG_DIR/auth_type

echo "1" > $CONFIG_DIR/wsc_configured
echo "1" > $CONFIG_DIR/wsc_auth
echo "2" > $CONFIG_DIR/wsc_enc
echo "0" > $CONFIG_DIR/wsc_configbyextreg

#$SCRIPT_DIR/init.sh


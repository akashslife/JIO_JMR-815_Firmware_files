#!/bin/sh

if [ $# -lt 1 ]; then echo "Usage: $0 iface";  exit 1 ; fi

CONFIG_ROOT_DIR="/var/rtl8192c"
CONFIG_DIR=$CONFIG_ROOT_DIR/$1

if [ -z "$SCRIPT_DIR" ]; then
	SCRIPT_DIR=`cat $CONFIG_ROOT_DIR/wifi_script_dir`
fi

BR_INTERFACE=br0
BR_LAN1_INTERFACE=eth0

###### setting ######
WLAN_IP=172.20.10.2
WLAN_NETMASK=255.255.0.0
WLAN_GW=172.20.10.254
RADIUS_SERVER_IP=172.20.10.250
RADIUS_SERVER_PORT=1812
RADIUS_SERVER_PASSWORD=12345678
#####################

#$SCRIPT_DIR/default_setting.sh $1

echo "0" > $CONFIG_DIR/wlan_mode
echo "$RADIUS_SERVER_IP" > $CONFIG_DIR/rs_ip
echo "$RADIUS_SERVER_PORT" > $CONFIG_DIR/rs_port
echo "$RADIUS_SERVER_PASSWORD" > $CONFIG_DIR/rs_password


echo "6" > $CONFIG_DIR/encrypt
echo "1" > $CONFIG_DIR/wep
echo "1" > $CONFIG_DIR/wpa_auth
echo "3" > $CONFIG_DIR/wpa_cipher
echo "3" > $CONFIG_DIR/wpa2_cipher

echo "1" > $CONFIG_DIR/wsc_configured
echo "34" > $CONFIG_DIR/wsc_auth
echo "12" > $CONFIG_DIR/wsc_enc
echo "" > $CONFIG_DIR/wsc_psk
echo "0" > $CONFIG_DIR/wsc_configbyextreg

echo "87654321" > $CONFIG_DIR/wpa_psk
echo "0" > $CONFIG_DIR/psk_format

echo "0" > $CONFIG_DIR/wpa11w
echo "0" > $CONFIG_DIR/wpa2EnableSHA256
#$SCRIPT_DIR/init.sh


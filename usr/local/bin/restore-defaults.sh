#!/bin/sh
#Export the relevent interfaces name
. /usr/local/bin/lte-gw-global-env.sh

TARGET_DIR="/nvm/etc/config"
SOURCE_DIR="/nvm_defaults/etc/config"
CONFIGURATION_DEFS_PATH='/configuration_defaults'
#SMS_FOLDERS='/nvm/etc/sms*'
LTEPP_FILE='/nvm/bsp/ltepp'
NVM_LOGS='/nvm/Logs'
NVM_CRUSH_LOGS='/nvm/CrushDumps'
ARGC=$#

remove_nvm_logs()
{
    echo ">>> Cleaning old Logs"
    rm -rf $NVM_LOGS/*
    rm -rf $NVM_CRUSH_LOGS/*
}
copy_operator_files()
{
# copy operator related config files

    if [ -e /etc/operators/$OPERATOR ]; then
        OPER_PATH='/etc/operators/'$OPERATOR
    else
        OPER_PATH='/etc/operators/default'
        OPERATOR='default'
    fi

    if [ -e $OPER_PATH ]; then
        cp -rf $OPER_PATH/config/* $TARGET_DIR
        cp -rf $OPER_PATH/scripts/* /usr/local/bin/
        echo ">>> Copy Operator configurations for $OPERATOR >>>" > /dev/kmsg
    else
        echo ">>> Error - path missing: $OPER_PATH >>>" > /dev/kmsg
    fi    
}

# Get Operator:
OPERATOR=`uci get -q service.Mode.Operator`
if [ -z "$OPERATOR" ]
then
    OPERATOR='default'
fi

save_persistent_data()
{
    cp -f $TARGET_DIR/APNTable /tmp/ > /dev/null 2>&1
    cp -f $TARGET_DIR/lwm2m /tmp/ > /dev/null 2>&1
    
}

recover_persistent_data()
{
	cp -f /tmp/APNTable $TARGET_DIR/ > /dev/null 2>&1
    cp -f /tmp/lwm2m $TARGET_DIR/ > /dev/null 2>&1
    
}

echo ">>> Restoring factory defaults >>>"

if [ $# -ne 0 ] ; then
	if [ $1 == "-s" ]  
	then
	    save_persistent_data
	fi
fi

remove_nvm_logs

rm -rf $TARGET_DIR/*
cp -rf $SOURCE_DIR/* $TARGET_DIR
copy_operator_files
mv $TARGET_DIR/version $TARGET_DIR/version_tmp

if [ $# -ne 0 ] ; then
	if [ $1 == "-s" ]
	then
	    recover_persistent_data
	fi
fi
if [ -e /proc/device-tree/configuration ]; then
	PROJECT_CONFIGURATION=$(cat /proc/device-tree/configuration);
	cp -rfL $CONFIGURATION_DEFS_PATH/$PROJECT_CONFIGURATION/* /
fi

echo ">>> Original configuration restored (rebooting...) >>>"

# Zero memory allocations for Debug Streamer and Sniffer. Requires reboot to take affect.
`fw_setenv phy_dbgstreamer 0`
`fw_setenv phy_sniffer 0`
sync

`/usr/local/bin/dhcp-ctrl.sh stop > /dev/null 2>&1`
#Configure DHCP params for router / bridge
sh /usr/local/bin/dhcp-conf.sh

# Erase SMS storage
#rm -rf $SMS_FOLDERS #no use ntmore

# Erase LTEPP bsp file
rm -rf $LTEPP_FILE

sync
sync
mv $TARGET_DIR/version_tmp $TARGET_DIR/version
echo ">>> Original configuration restored (rebooting...) >>>"

sync
sync
sleep 1

if [ $PROJECT_CONFIGURATION == "PWRT" ];then
	# Enable the PMIC 32KHz in order to allow reboot command, i.e. via MASTER_SOFT_RST register
	/etc/init.d/S99set_pmic_32Khz_osc stop
fi

#NTmore added
#jclee,150305, restore wifi config files
rm -rf /var/rtl8192c
/root/script/default_setting.sh wlan0 ap
/root/script/default_setting.sh wlan0-va0 ap

#jclee,150916, restore dop at command config
if [ -f /nvm/bsp/dop.default ];then
	if [ $(diff -Nur /nvm/bsp/dop /nvm/bsp/dop.default |wc -l) -ne 0 ];then
		cp -rf /nvm/bsp/dop.default /nvm/bsp/dop
		sync
	fi
fi

fw_setenv reboot 1
sync
echo "Config Reset" >/etc/config/reason_start
#reboot -f #ntmore block -f option
reboot


CONFIG_PATH=/etc/config
CONFIG_PATH_DEFAULT_PROJECT=/configuration_defaults/PWRT/nvm/etc/config
CONFIG_PATH_DEFAULT=/nvm_defaults/etc/config


enable()
{

uci set $CONFIG_PATH/lte-gw.embms.inband_enable="enable"
uci commit $CONFIG_PATH/lte-gw

uci set $CONFIG_PATH_DEFAULT_PROJECT/lte-gw.embms.inband_enable="enable"
uci commit $CONFIG_PATH_DEFAULT_PROJECT/lte-gw

uci set $CONFIG_PATH/wifi_config.misc.mal="enable"
uci commit $CONFIG_PATH/wifi_config

uci set $CONFIG_PATH_DEFAULT/wifi_config.misc.mal="enable"
uci commit $CONFIG_PATH_DEFAULT/wifi_config

fw_setenv reboot 1
sync

reboot

}

disable()
{

uci set $CONFIG_PATH/lte-gw.embms.inband_enable="disable"
uci commit $CONFIG_PATH/lte-gw

uci set $CONFIG_PATH_DEFAULT_PROJECT/lte-gw.embms.inband_enable="disable"
uci commit $CONFIG_PATH_DEFAULT_PROJECT/lte-gw

uci set $CONFIG_PATH/wifi_config.misc.mal="disable"
uci commit $CONFIG_PATH/wifi_config

uci set $CONFIG_PATH_DEFAULT/wifi_config.misc.mal="disable"
uci commit $CONFIG_PATH_DEFAULT/wifi_config

fw_setenv reboot 1
sync

reboot


}


case "$1" in                                                                                         
    enable)    
		echo "embms enabled...reboot device"
    	enable
        ;;                                                             

    disable) 
		echo "embms disabled...reboot device"	
		disable
		;;
esac



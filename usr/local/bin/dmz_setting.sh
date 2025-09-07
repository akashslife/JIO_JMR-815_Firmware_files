enable(){
echo "DMZ Setting Enable"
uci set /etc/config/lte-gw.nat.dmz_enable=enable 
uci set /etc/config/lte-gw.nat.dmz_host_ip=$1
/usr/local/bin/nat-conf.sh
}

disable(){
echo "DMZ Setting Disable"
uci set /etc/config/lte-gw.nat.dmz_enable=disable
uci set /etc/config/lte-gw.nat.dmz_host_ip='0.0.0.0'
/usr/local/bin/nat-conf.sh
}

help(){
        echo ""
        echo "===== how to used ====="
        echo "[DMZ Enable]"
        echo "dmz_setting.sh enable [IP Address]"
        echo "ex) dmz_setting.sh enable 192.168.15.123"
        echo "[DMZ Disable]"
        echo "dmz_setting.sh disable"
        echo "ex) dmz_setting.sh disable"
        echo ""
}
case "$1" in
    enable)
        enable $2
        ;;
    disable)
        disable
        ;;
    -h)
        help
        ;;
    *)
        help
        ;;
esac


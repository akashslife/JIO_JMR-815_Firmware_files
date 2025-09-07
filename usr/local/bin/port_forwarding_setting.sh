add(){
echo "port fowarding add"
FWD_NUM=`uci get /etc/config/lte-gw.nat.port_fwd_num`
FWD_NUM=`expr $FWD_NUM + 1`
uci set /etc/config/lte-gw.nat.port_fwd_num=$FWD_NUM
uci commit /etc/config/lte-gw

uci add /etc/config/lte-gw-port-fwd port_fwd
FWD_NUM=`expr $FWD_NUM - 1`
uci set /etc/config/lte-gw-port-fwd.@port_fwd[$FWD_NUM].enable=enable
uci set /etc/config/lte-gw-port-fwd.@port_fwd[$FWD_NUM].src_ip_addr=all
if test "TCP" = $4
then
uci set /etc/config/lte-gw-port-fwd.@port_fwd[$FWD_NUM].protocol=tcp
else
uci set /etc/config/lte-gw-port-fwd.@port_fwd[$FWD_NUM].protocol=udp
fi
uci set /etc/config/lte-gw-port-fwd.@port_fwd[$FWD_NUM].ext_port_from=$2
uci set /etc/config/lte-gw-port-fwd.@port_fwd[$FWD_NUM].ext_port_to=$3
uci set /etc/config/lte-gw-port-fwd.@port_fwd[$FWD_NUM].dst_ip_addr=$1
uci set /etc/config/lte-gw-port-fwd.@port_fwd[$FWD_NUM].description=None
if test $2 = $3
then
uci set /etc/config/lte-gw-port-fwd.@port_fwd[$FWD_NUM].dst_port=$2
else
uci set /etc/config/lte-gw-port-fwd.@port_fwd[$FWD_NUM].dst_port=$2-$3
fi

uci commit /etc/config/lte-gw-port-fwd
/usr/local/bin/nat-conf.sh > /dev/NULL
}

deleteall(){
echo "" >/etc/config/lte-gw-port-fwd
uci set /etc/config/lte-gw.nat.port_fwd_num=0
uci commit /etc/config/lte-gw-port-fwd
/usr/local/bin/nat-conf.sh > /dev/NULL
}

help(){
        echo ""
        echo "===== how to used ====="
        echo "[Port Forwarding Enable]"
        echo "port_forwarding_setting.sh add [IP_Address] [PROT_FROM] [PORT_TO] [PROTOCOL]"
        echo "[PROTOCOL] : UDP or TCP"
        echo "ex) port_forwarding_setting.sh add 192.168.15.123 9001 9001 UDP"
        echo "[Port Forwarding delete]"
        echo "port_forwarding_setting.sh deleteall"
        echo "ex) port_forwarding_setting.sh deleteall"
        echo ""
}

case "$1" in
    add)
        add $2 $3 $4 $5
        ;;
    deleteall)
        deleteall
        ;;
    -h)
        help
        ;;
    *)
        help
        ;;

esac


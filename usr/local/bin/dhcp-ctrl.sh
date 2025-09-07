#!/bin/sh

#!/bin/sh

# GPL $Id: dnsmasq,v 1.2 2005/03/22 15:06:14 cvonk Exp $
# system init for DNS forwarder and DHCP server (dnsmasq)

PID_FILE="/var/run/dnsmasq.pid"
DHCP_SRV_ENABLE=`uci get lte-gw.dhcp_srv.dhcp_enable`
MODE=`uci get lte-gw.local_param.local_topoloy`

case "$1" in
    start)
        if [ $DHCP_SRV_ENABLE == "enable" -o $MODE = "router" ]
        then
            #create the dhcp reservation file after reboot
            /usr/local/bin/dhcp-conf.sh init

            #the dnsmasq.more.conf and /tmp/dnsmasq.dhcp.opt.conf files must be exist
            touch /tmp/dnsmasq.more.conf
            touch /tmp/dnsmasq.dhcp.opt.conf

            dnsmasq -C /etc/dnsmasq.conf -l /tmp/dnsmasq.leases --dhcp-hostsfile="/tmp/dhcp-hosts.conf" --pid-file=$PID_FILE --no-ping --dhcp-script=/etc/dnsmasq.script
        fi
        ;;
    stop)
        if [ -f $PID_FILE ]; then
            PID=`cat $PID_FILE`
            if [ -n $PID ]; then
                kill -9 $PID > /dev/null 2>&1
            fi
        fi
        ;;
    restart)
    $0 stop
    $0 start
    ;;
    refresh)
    #send sig hup to the dnsmasq will not read configuration file but will read dhcp opt file.
	kill -HUP `cat /var/run/dnsmasq.pid`
    ;;
    status)
        if [ -f $PID_FILE ]; then
            PID=`cat $PID_FILE`
            if [ -n $PID ]; then
                kill -0 $PID > /dev/null 2>&1
                if [ `echo $?` == 0 ]; then
                    echo "running"
                    exit 0
                fi
            fi
        fi
        echo "stopped"
        ;;
esac



#!/bin/sh -x
# $Id: miniupnpd.init.d.script,v 1.3 2012/03/14 22:09:53 nanard Exp $
# MiniUPnP project
# author: Thomas Bernard
# website: http://miniupnp.free.fr/ or http://miniupnp.tuxfamily.org/


UPNP_EXTIF=`uci get lte-gw.nat.upnp_wan_if 2> /dev/null`
if [ $? -ne 0 ];
then
     echo "didnt find upnp in uci" > /dev/kmsg
     exit 0
fi

EXE="/usr/local/bin/upnp.sh"
CONF_FILE="/etc/miniupnpd/miniupnpd.conf"
MINIUPNPD="/usr/bin/miniupnpd"
TMP_CONF_FILE="/tmp/miniupnpd.conf"
ARGS="-f $TMP_CONF_FILE"

IPTABLES_CREATE=/etc/miniupnpd/iptables_init.sh
IPTABLES_REMOVE=/etc/miniupnpd/iptables_removeall.sh

case "$1" in
  start)

        echo "UPnP start" > /dev/kmsg
        
        UPNP_MODE=`uci get lte-gw.nat.upnp_mode 2> /dev/null`
        if [ $? -ne 0 ];
        then
            echo "didnt find upnp in uci" > /dev/kmsg
            exit 0
        fi
        
        if [ $UPNP_MODE == "disable" ]
        then
                echo "UPnP disabled" > /dev/kmsg
                exit 0
        fi
        
        #check if config file exist in /tmp/
        if [ ! -f $TMP_CONF_FILE ]
        then
            cp $CONF_FILE $TMP_CONF_FILE

#            LOCAL_SUBNET=`uci get lte-gw.local_param.local_ip_addr | awk -F. '{print $1"."$2"."$3".0/24"}'`
#            echo "allow 1024-65535 $LOCAL_SUBNET 1024-65535" >> $TMP_CONF_FILE
#            echo "deny 0-65535 0.0.0.0/0 0-65535" >>  $TMP_CONF_FILE            
        fi

        INTERNET_INTERACE_FILE='/tmp/internet_if.txt'
        #Check the the file exist.
        if [ ! -e $INTERNET_INTERACE_FILE ]
        then
            EXTIF=`uci get lte-gw.nat.upnp_wan_if`
        else
            #The internet LTE interface lte0 / lte0.1 etc...
            EXTIF=`cat $INTERNET_INTERACE_FILE` 
        fi
        
        #change WAN if name
        sed -i -e "s/^ext_ifname=.*$/ext_ifname=$EXTIF/g" $TMP_CONF_FILE

        # iptables chains rules will be created from nat-conf.sh 		
        $IPTABLES_CREATE > /dev/null 2>&1
        miniupnpd $ARGS
        ;;
  stop)
        echo "UPnP stop" > /dev/kmsg
        killall miniupnpd  > /dev/null 2>&1
        $IPTABLES_REMOVE > /dev/null 2>&1
        ;;
  restart|reload|force-reload)
        `$EXE stop`
        `$EXE start`
        ;;
        
  new-ip)
    #First check if miniupnp is already running.
    #if not exit
    echo "UPnP new LTE IP" > /dev/kmsg
    
    kill -0 `cat /var/run/miniupnpd.pid 2>/dev/null` > /dev/null 2>&1
    if [ $? != '0' ]
    then
        echo "UPnP not started yet" > /dev/kmsg
        exit 0;
    else
    #If miniupnpd is already running, we need to re-add iptables chain and rules and restart it on the new interface
    #No need to remove iptables rule as they where deleted from nat-conf.sh
    echo "UPnP stop" > /dev/kmsg
    killall miniupnpd  > /dev/null 2>&1
    `$EXE start`    
    fi
  ;;
        
  *)
        echo "Usage: /etc/init.d/miniupnpd {start|stop|restart|reload|force-reload} wan_if (lte0.1 ...)"
        exit 2
        ;;
esac
exit 0

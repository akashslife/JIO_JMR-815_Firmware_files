#!/bin/sh
source /etc/functions.sh
source /lib/network/config.sh

firewall_up() {
        local wan
        wan="`cat /tmp/wan`"

        echo 1 >/proc/sys/net/ipv4/ip_forward
        iptables -t nat -A POSTROUTING -o "${wan}" -j MASQUERADE
        iptables -A INPUT -j LED --led-trigger-id lednet --led-delay 100
        iptables -A FORWARD -j LED --led-trigger-id lednet --led-delay 100
}

firewall_down() {
        echo 0 >/proc/sys/net/ipv4/ip_forward
        iptables -t nat -F POSTROUTING
        iptables -F INPUT
        iptables -F FORWARD
}

case "$1" in                                  
start)                                        
        firewall_up                          
        ;;                                   
stop)                                        
        firewall_down                        
        ;;                            
force-reload|restart)      
        ;;                 
*)                 
        echo "Usage: $0 {start|stop}"
        exit 1       
        ;;           
esac                 
                     
exit 0

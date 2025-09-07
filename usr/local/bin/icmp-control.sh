#!/bin/sh


enable_icmp() {

    #sleep before enabling
    sleep $1 > /dev/null 2>&1

    #Delete ICMP droping rule
#    ebtables -t broute -D BROUTING -p IPV4 --ip-proto icmp -j DROP > /dev/null 2>&1
    ebtables -t filter -D INPUT -p IPV4 --ip-proto icmp -j DROP
#    ebtables -t filter -D FORWARD -p IPV4 --ip-proto icmp -j DROP
}


disable_icmp() {
    #Add ICMP droping rule
#    ebtables -t broute -A BROUTING -p IPV4 --ip-proto icmp -j DROP  > /dev/null 2>&1
    ebtables -t filter -A INPUT -p IPV4 --ip-proto icmp -j DROP
#   ebtables -t filter -A FORWARD -p IPV4 --ip-proto icmp -j DROP
  
}

case "$1" in
    enable)
        enable_icmp $2
        ;;
    disable)
        disable_icmp
        ;;
    status)
       ebtables -t broute -L --Lc | grep icmp
        ;;
esac

#!/bin/sh

catch_bridge_traffic() {
    #Delete ICMP droping rule
    ebtables -t broute -A BROUTING -j DROP  > /dev/null 2>&1
}


uncatch_bridge_traffic() {
    #Add ICMP droping rule
    ebtables -t broute -D BROUTING -j DROP  > /dev/null 2>&1
}

case "$1" in
    enable)
        catch_bridge_traffic
        ;;
    disable)
        uncatch_bridge_traffic
        ;;
    status)
       ebtables -t broute -L --Lc 
        ;;
esac

#!/bin/sh

socatRelayRunner="/etc/ue_lte/relaySocatRunner.sh"
socatSource='-b33000 -u /dev/uestreamer0'

# $1 - Target Host IP address in case of relay over network 
prepToRelay() {
    streamerTtyif=`uci -q get lte-gw.debug_streamer.tty_if`
    
    # Test if configured to relay to tty device - exit
    if [[ "$streamerTtyif" !=  "none" ]]; then
        exit 0
    else # Streamer over socket
        IPADDR=$1 #In this case we expect IP address to be supplied

        # "none" is a valid option that can be configured in the lte-gw configuration file as the in static target host IP
        if [[ "$IPADDR" == "none" ]] || [[ -z "$IPADDR" ]]; then
            exit 0 # Nothing to do
        fi

        socat_target="UDP4-DATAGRAM:${IPADDR}:7399"
        relayMessage=">>> relaying Debug Streamer to Host ${IPADDR}:7399 <<<"
    fi
}

case "$1" in
    start)
        prepToRelay $2
        $socatRelayRunner "$socatSource $socat_target" "$relayMessage"
        ;;
    stop)
        ps | grep -e "-u /dev/uestreame[r]0" | awk '{print $1}' | xargs kill -9 2>/dev/null
        ;;
    restart)
	    prepToRelay $2
	    # Stop any active
	    ps | grep -e "-u /dev/uestreame[r]0" | awk '{print $1}' | xargs kill -9 2>/dev/null
	    # start relay
	    $socatRelayRunner "$socatSource $socat_target" "$relayMessage"
        ;;
    *)
        echo "Usage: $0 {start [IPADDR]|stop|restart [IPADDR]}" > /dev/kmsg
        exit 1
esac

exit $?


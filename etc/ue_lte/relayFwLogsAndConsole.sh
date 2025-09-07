#!/bin/sh

socatRelayRunner="/etc/ue_lte/relaySocatRunner.sh"
socatLogSource='-b1450 -u /dev/ueservice0'
socatConsoleTarget='/dev/ueservice0,ignoreeof'

# $1 - Target Host IP address in case of relay over network 
prepToRelay() {
    logsIf=`uci -q get lte-gw.modem_fw_logs.tty_if`

    # Test if configured to relay to tty device simply by testing if the defined interface is a char device
    if [[ "$logsIf" !=  "none" ]]; then
        exit 0
    else # Log and Console over socket
        IPADDR=$1 #In this case we expect IP address to be supplied

        # In the init flow - while no host ip is known "none" value is the default if no 
        # specific IP address was set in the configuration file.
        if [[ "$IPADDR" == "none" ]] || [[ -z "$IPADDR" ]]; then
            exit 0 # Nothing to do
        fi

        socatLogTarget="UDP4-DATAGRAM:${IPADDR}:4566"
        relayModemFwLogsMessage=">>> relaying LOGS/Console to ${IPADDR}  <<<"

        socatConsoleSource="UDP4-RECV:11113,ignoreeof"
        relayConsoleCmdsMessage=">>> relaying Console commands from UDP port:11113 <<<"
    fi
}

case "$1" in
    start)
        prepToRelay $2
        $socatRelayRunner "$socatLogSource $socatLogTarget" "$relayModemFwLogsMessage"
        $socatRelayRunner "-u $socatConsoleSource $socatConsoleTarget" "$relayConsoleCmdsMessage"
        ;;
    stop)
        ps | grep " /dev/ueservic[e]0" | awk '{print $1}' | xargs kill -9 2>/dev/null
        ;;
    restart)
        prepToRelay $2
        # Stop any active
        ps | grep " /dev/ueservic[e]0" | awk '{print $1}' | xargs kill -9 2>/dev/null
        # start relays
        $socatRelayRunner "$socatLogSource $socatLogTarget" "$relayModemFwLogsMessage"
        $socatRelayRunner "-u $socatConsoleSource $socatConsoleTarget" "$relayConsoleCmdsMessage"
        ;;
    *)
        echo "Usage: $0 {start [IPADDR]|stop|restart [IPADDR]}" > /dev/kmsg
        exit 1
esac

exit $?

#!/bin/sh

CONSOLE_TTY=`uci -q get /etc/config/lte-gw.econsole.tty_if` 

prepToRelay() {
 
  IPADDR=$1
  
  # Test if configured to relay console commands - EXIT
  if [[ "$CONSOLE_TTY" !=  "none" ]]; then
       exit 0
  else
    # In the init flow - while no host ip is known "none" value is the default if no 
    # specific IP address was set in the configuration file.
    if [[ "$IPADDR" == "none" ]] || [[ -z "$IPADDR" ]]; then
       echo "No IP for console exit" > /dev/kmsg
       exit 0 # Nothing to do
    fi
    
    console_in="-u UDP4-RECV:11113,ignoreeof PIPE:/tmp/console_in,ignoreeof,unlink-close=0"
    console_out="-d -d -b1450 -u PIPE:/tmp/console_out,unlink-close=0 UDP4-DATAGRAM:${IPADDR}:4566"
    relayConsoleInMessage=">>> relaying Console commands from UDP port:11113 <<<"
    relayConsoleOutMessage=">>> relaying Console response to ${IPADDR}  <<<"
  fi
}

# Prepare for socat creation
prepToRelay $2
# Kill runnig socats
ps | grep relayConsoleSocatRunne[r] | awk '{print $1}' |xargs kill -9 2>/dev/null
ps | grep -E "socat.*(console_ou[t]|console_i[n])" | awk '{print $1}' | xargs kill -9 2>/dev/null
# Run new socats
/etc/ue_lte/relayConsoleSocatRunner.sh "$console_in" "$relayConsoleInMessage" &
/etc/ue_lte/relayConsoleSocatRunner.sh "$console_out" "$relayConsoleOutMessage" &



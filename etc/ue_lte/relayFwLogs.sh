#!/bin/sh

LOGS_TTY=`uci -q get /etc/config/lte-gw.modem_fw_logs.tty_if`

prepToRelay() {

  IPADDR=$1
  
  # Test if configured to relay LOGS to tty - exit
  if [[ "$LOGS_TTY" !=  "none" ]]; then
      exit 0
  else
    # In the init flow - while no host ip is known "none" value is the default if no 
    # specific IP address was set in the configuration file.
    if [[ "$IPADDR" == "none" ]] || [[ -z "$IPADDR" ]]; then
      echo "No IP for log exit" > /dev/kmsg
      exit 0 # Nothing to do
    fi
    log_out="-d -d -u PIPE:/tmp/log_out,unlink-close=0 UDP4-DATAGRAM:${IPADDR}:18455"  
    relayLogMessage=">>> Relaying LOGS to ${IPADDR}:18455 <<<"
  fi
}


# prepare for socat creation
prepToRelay $2
# kill runnig socats
ps | grep relayLogSocatRunne[r] | awk '{print $1}' |xargs kill -9 2>/dev/null
ps | grep -E "socat.*(log_ou[t])" | awk '{print $1}' | xargs kill -9 2>/dev/null
# run new socats
/etc/ue_lte/relayLogSocatRunner.sh "$log_out" "$relayLogMessage" &



#!/bin/sh

TTYIF=`uci get elc.interface.tty_if`

echo "Relaying TTY $TTYIF"

while [ 1 ]
do
	socat -u $TTYIF,raw,echo=0 /tmp/nmea0,reuseaddr,nonblock 
	sleep 1
done





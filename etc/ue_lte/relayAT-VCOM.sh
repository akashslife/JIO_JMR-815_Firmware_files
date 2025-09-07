#!/bin/sh

ttydev=/dev/$1

startRelayAtOverTty() {
    echo "Relaying AT commands over device $ttydev"
    while [ 1 ]
		do
		   socat -d -d /tmp/atsw9,reuseaddr,nonblock $ttydev,raw,echo=0
		   sleep 1
	done
}

if [[ -c "$ttydev" ]]; then
    startRelayAtOverTty &
fi

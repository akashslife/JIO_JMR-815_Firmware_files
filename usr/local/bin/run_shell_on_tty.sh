#!/bin/sh

ttydev="/dev/$1"

startRelayShellOverTty() {
    echo "Starting Linux Shell on usb serial gadget $ttydev"
	while [ 1 ]; do
		sh > $ttydev  2>$ttydev <$ttydev
		sleep 1
	done
}

if [[ -c "$ttydev" ]]; then
    startRelayShellOverTty &
fi

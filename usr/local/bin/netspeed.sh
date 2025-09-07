#!/bin/sh

RX=0
TX=0

_die() {
    printf '%s\n' "$@"
    exit 1
}

_interface=wlan0

_interface_bytes_in_old=$(awk "/^ *${_interface}:/"' { if ($1 ~ /.*:[0-9][0-9]*/) { sub(/^.*:/, "") ; print $1 } else { print $2 } }' /proc/net/dev)
_interface_bytes_out_old=$(awk "/^ *${_interface}:/"' { if ($1 ~ /.*:[0-9][0-9]*/) { print $9 } else { print $10 } }' /proc/net/dev)

while sleep 3; do

grep -q $_interface /proc/net/dev
RET=`echo $?`

if [ $RET == 0 ]; then 
    _interface_bytes_in_new=$(awk "/^ *${_interface}:/"' { if ($1 ~ /.*:[0-9][0-9]*/) { sub(/^.*:/, "") ; print $1 } else { print $2 } }' /proc/net/dev)
    _interface_bytes_out_new=$(awk "/^ *${_interface}:/"' { if ($1 ~ /.*:[0-9][0-9]*/) { print $9 } else { print $10 } }' /proc/net/dev)

	let RX=$(( _interface_bytes_in_new - _interface_bytes_in_old ))
	let TX=$(( _interface_bytes_out_new - _interface_bytes_out_old ))
	let "RX= $RX * 8"
	let "RX= $RX / 3000"
	let "TX= $TX * 8"
	let "TX= $TX / 3000"

	db_writer -c downlink "$_interface_bytes_in_old,$RX" uplink "$_interface_bytes_out_old,$TX"
	_interface_bytes_in_old=${_interface_bytes_in_new}
    _interface_bytes_out_old=${_interface_bytes_out_new}

else
	db_writer -c downlink "0,0" uplink "0,0"
fi
	
	
done

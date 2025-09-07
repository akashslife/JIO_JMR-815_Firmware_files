#!/bin/sh

dbgStreamerEnable=$(/usr/bin/uci get /etc/config/lte-gw.loging_param.debug_streamer)
if [ "$dbgStreamerEnable" == "enable" ]; then
   let dbgStreamerEnable=1
else
   let dbgStreamerEnable=0
fi

dbgStreamerAddr=$(find /proc/device-tree -name debug_streamer_addr)
dbgStreamerSize=$(find /proc/device-tree -name debug_streamer_size)

if [ "$dbgStreamerAddr" == "" ]; then
	let dbgStreamerAddr=0xffffffff;
else
	dbgStreamerAddr=$(cat $dbgStreamerAddr | hexdump -e '"%x"')
	dbgStreamerAddr='0xa'$dbgStreamerAddr
fi
if [ "$dbgStreamerSize" == "" ]; then
	let dbgStreamerSize=0;
else
	let dbgStreamerSize=$(cat $dbgStreamerSize | hexdump -e '"%d"')
fi
let DBG_STREAMER_SIZE_MB=$dbgStreamerSize/1024/1024;

snifferEnable=$(/usr/bin/uci get /etc/config/lte-gw.loging_param.sniffer)
if [ "$snifferEnable" == "enable" ]; then
   let snifferEnable=1
else
   let snifferEnable=0
fi

snifferAddr=$(find /proc/device-tree -name sniffer_addr)
snifferSize=$(find /proc/device-tree -name sniffer_size)

if [ "$snifferAddr" == "" ]; then
	let snifferAddr=0xffffffff;
else
	snifferAddr=$(cat $snifferAddr | hexdump -e '"%x"')
	snifferAddr='0xa'$snifferAddr
fi
if [ "$snifferSize" == "" ]; then
	echo "Sniffer config not found" > /dev/kmsg
	let snifferSize=0;
else
	let snifferSize=$(cat $snifferSize | hexdump -e '"%d"')
fi
let SNIFFER_SIZE_MB=$snifferSize/1024/1024;

echo "$dbgStreamerEnable,$dbgStreamerAddr,$DBG_STREAMER_SIZE_MB,$snifferEnable,$snifferAddr,$SNIFFER_SIZE_MB,"



#!/bin/sh
TABLE=$1
IP=$2
IPV6=$(echo $IP | grep : -c)
if [ $IPV6 != 0 ]
then 
IP_PARAM="-6"
fi

if [ $(ip $IP_PARAM rule | grep $TABLE -c) -eq 0 ]
then
  echo $0: ip $IP_PARAM rule add from $IP table $TABLE > dev/kmsg
  ip $IP_PARAM rule add from $IP table $TABLE > dev/kmsg
else
  echo $0: table $TABLE already exists > dev/kmsg
fi

#!/bin/sh

if [ $# -ne 0 ]; then
 
 IP_UE=$1
 IP_PROXY=$2			

 PORT_PC=$3
 PORT_PS=$4
 PORT_UC=$5			
 PORT_US=$6

 SPI_PC=$7
 SPI_PS=$8
 SPI_UC=$9
 SPI_US=$10			

else
 # test mode
 IP_UE="fe80::211:22ff:fe33:4455"
 IP_PROXY="fe80::211:22ff:fe33:4456"			

 PORT_PC="5066"
 PORT_PS="5068"
 PORT_UC="5062"			
 PORT_US="5064"	

 SPI_PC="3333"
 SPI_PS="4444"
 SPI_UC="1111"
 SPI_US="2222"	
fi

#Incoming Requests [US <- PC]
ip xfrm policy delete src $IP_PROXY dst $IP_UE proto udp sport $PORT_PC dport $PORT_US dir in
ip xfrm policy delete src $IP_PROXY dst $IP_UE proto tcp sport $PORT_PC dport $PORT_US dir in
ip xfrm state delete src $IP_PROXY dst $IP_UE proto esp spi $SPI_US

#Incoming Replies [UC <- PS]
ip xfrm policy delete src $IP_PROXY dst $IP_UE proto udp sport $PORT_PS dport $PORT_UC dir in
ip xfrm policy delete src $IP_PROXY dst $IP_UE proto tcp sport $PORT_PS dport $PORT_UC dir in
ip xfrm state delete src $IP_PROXY dst $IP_UE proto esp spi $SPI_UC

#Outgoing Requests [UC -> PS]
ip xfrm policy delete src $IP_UE dst $IP_PROXY proto udp sport $PORT_UC dport $PORT_PS dir out
ip xfrm policy delete src $IP_UE dst $IP_PROXY proto tcp sport $PORT_UC dport $PORT_PS dir out
ip xfrm state delete src $IP_UE dst $IP_PROXY proto esp spi $SPI_PS

#Outgoing Replies [US -> PC]
ip xfrm policy delete src $IP_UE dst $IP_PROXY proto udp sport $PORT_US dport $PORT_PC dir out
ip xfrm policy delete src $IP_UE dst $IP_PROXY proto tcp sport $PORT_US dport $PORT_PC dir out
ip xfrm state delete src $IP_UE dst $IP_PROXY proto esp spi $SPI_PC

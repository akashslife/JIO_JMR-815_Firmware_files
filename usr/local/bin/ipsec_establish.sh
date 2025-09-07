#!/bin/sh

if [ $# -ne 0 ]; then

 IP_UE="$1"
 IP_PROXY="$2"

 MODE="$3"
 # convert for SIP to XFRM format
 if [ "$4" = "hmac-md5-96" ]; then
  AUTH="hmac(md5)"
 elif [ "$4" = "hmac-sha-1-96" ]; then
  AUTH="hmac(sha1)"
 else
  AUTH="$4"
  echo "WARN! Unknown AUTH $4"
 fi
 AUTH_KEY="$5"

 if [ "$7" = "NA" ]; then
  ENC="cipher_null"
#  ENC_KEY="\"\""        # not working with variable, currerntly encypyion is not needed so hard coded is being used
 else
  if [ "$6" = "des-ede3-cbc" ]; then
   ENC="cbc(des3_ede)"
  elif [ "$6" = "aes-cbc" ]; then
   ENC="cbc(aes)"
  else
   ENC="$6"
   echo "WARN! Unknown ENC $6"
  fi

  ENC_KEY="$7"
 fi

 PORT_PC=$8
 PORT_PS=$9
 PORT_UC=$10			
 PORT_US=$11			

 SPI_PC=$12
 SPI_PS=$13
 SPI_UC=$14			
 SPI_US=$15				

else
 # xfrm test mode
 IP_UE="fe80::211:22ff:fe33:4455"
 IP_PROXY="fe80::211:22ff:fe33:4456"

 MODE="transport"

 AUTH="hmac(md5)"
 AUTH_KEY="0x96358c90783bbfa3d7b196ceabe0536b"
 # AUTH="hmac(sha1)"
 # AUTH_KEY="0x96358c90783bbfa3d7b196ceabe0536b10111213"
 #disable encription
 #ENC="cipher_null"
 #ENC_KEY=''

 #ENC="cbc(des3_ede)"
 #ENC_KEY="0xf6ddb555acfd9d77b03ea3843f2653255afe8eb5573965df"

 ENC="cbc(aes)"
 ENC_KEY="0x6aed4975adf006d65c76f63923a6265b"

 PORT_PC="5066"
 PORT_PS="5068"
 PORT_UC="5062"			
 PORT_US="5064"

 SPI_PC="3333"
 SPI_PS="4444"
 SPI_UC="1111"			
 SPI_US="2222"				
			
fi

#ip xfrm state deleteall
#ip xfrm policy deleteall

#Incoming Requests [US <- PC]
ip xfrm policy add src $IP_PROXY dst $IP_UE proto udp sport $PORT_PC dport $PORT_US dir in tmpl src $IP_PROXY dst $IP_UE proto esp mode $MODE reqid 1  
ip xfrm policy add src $IP_PROXY dst $IP_UE proto tcp sport $PORT_PC dport $PORT_US dir in tmpl src $IP_PROXY dst $IP_UE proto esp mode $MODE reqid 1
if [ "$ENC" = "cipher_null" ]; then
 modprobe crypto_null.ko  # needed only once
 ip xfrm state add src $IP_PROXY dst $IP_UE proto esp spi $SPI_US mode $MODE reqid 1 auth $AUTH $AUTH_KEY enc cipher_null ""
else
 ip xfrm state add src $IP_PROXY dst $IP_UE proto esp spi $SPI_US mode $MODE reqid 1 auth $AUTH $AUTH_KEY enc $ENC $ENC_KEY
fi

#Incoming Replies [UC <- PS]
ip xfrm policy add src $IP_PROXY dst $IP_UE proto udp sport $PORT_PS dport $PORT_UC dir in tmpl src $IP_PROXY dst $IP_UE proto esp mode $MODE reqid 2
ip xfrm policy add src $IP_PROXY dst $IP_UE proto tcp sport $PORT_PS dport $PORT_UC dir in tmpl src $IP_PROXY dst $IP_UE proto esp mode $MODE reqid 2
if [ "$ENC" = "cipher_null" ]; then
 ip xfrm state add src $IP_PROXY dst $IP_UE proto esp spi $SPI_UC mode $MODE reqid 2 auth $AUTH $AUTH_KEY enc cipher_null ""
else
 ip xfrm state add src $IP_PROXY dst $IP_UE proto esp spi $SPI_UC mode $MODE reqid 2 auth $AUTH $AUTH_KEY enc $ENC $ENC_KEY
fi

#Outgoing Requests [UC -> PS]
ip xfrm policy add src $IP_UE dst $IP_PROXY proto udp sport $PORT_UC dport $PORT_PS dir out tmpl src $IP_UE dst $IP_PROXY proto esp mode $MODE reqid 3
ip xfrm policy add src $IP_UE dst $IP_PROXY proto tcp sport $PORT_UC dport $PORT_PS dir out tmpl src $IP_UE dst $IP_PROXY proto esp mode $MODE reqid 3
if [ "$ENC" = "cipher_null" ]; then
 ip xfrm state add src $IP_UE dst $IP_PROXY proto esp spi $SPI_PS mode $MODE reqid 3 auth $AUTH $AUTH_KEY enc cipher_null ""
else
 ip xfrm state add src $IP_UE dst $IP_PROXY proto esp spi $SPI_PS mode $MODE reqid 3 auth $AUTH $AUTH_KEY enc $ENC $ENC_KEY
fi

#Outgoing Replies [US -> PC]
ip xfrm policy add src $IP_UE dst $IP_PROXY proto udp sport $PORT_US dport $PORT_PC dir out tmpl src $IP_UE dst $IP_PROXY proto esp mode $MODE reqid 4
ip xfrm policy add src $IP_UE dst $IP_PROXY proto tcp sport $PORT_US dport $PORT_PC dir out tmpl src $IP_UE dst $IP_PROXY proto esp mode $MODE reqid 4
if [ "$ENC" = "cipher_null" ]; then
 ip xfrm state add src $IP_UE dst $IP_PROXY proto esp spi $SPI_PC mode $MODE reqid 4 auth $AUTH $AUTH_KEY enc cipher_null ""
else
 ip xfrm state add src $IP_UE dst $IP_PROXY proto esp spi $SPI_PC mode $MODE reqid 4 auth $AUTH $AUTH_KEY enc $ENC $ENC_KEY
fi 




dmesg -C
ps | grep 'send-logs-to-tm\|amahub\|consold\|atswitch\|relay\|socat\|dnsmasq\|ue_fileif\|alt-ecm' | awk '{print $1'} | xargs kill -9 2>/dev/null

let ITERNUM=20
let i=0
while [ $i -lt $ITERNUM ]; do 
  rmmod ue_lte 2>/dev/null
  [[ $? -ne 0 ]] || break
  let i=$i+1
done 

if [ $i -eq $ITERNUM ] 
then
  exit 1
fi

rm -f /tmp/consol* /tmp/log_out

/etc/init.d/S07system_init start

ps | grep 'atswitch\|SMSManager\|imsclient\|opcat\|db_probe\|relayAT' | awk '{print $1'} | xargs kill -9 2>/dev/null

socat -d -d -ly /dev/ttyLTE0,raw,nonblock,ignoreeof,cr,echo=0 /dev/ttyGS0,raw,echo=0 &

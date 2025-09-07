#!/bin/sh
#
. /usr/local/bin/usb_util.sh

if [ ! -e /tmp/mass_one ];then
MASSONE='0'
else
MASSONE=`cat /tmp/mass_one`
fi
    
if [ $MASSONE = '1' ]; then
       echo "$0: sdcard mode is mass once " > /dev/kmsg
       exit
fi
   
rm_module_if_gadget_exist
	
	

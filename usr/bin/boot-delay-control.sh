#!/bin/sh

if [ $# -eq 1 ]; then
        BDELAY=$1
else
        BDELAY=0
fi

echo ">>> Setting boot delay to $BDELAY >>>"

if [ $BDELAY == 0 ]; then

    fw_setenv bootdelay 0
    fw_setenv en_usb_on_init 0 

else
    
    fw_setenv bootdelay $BDELAY
    fw_setenv en_usb_on_init 1

fi


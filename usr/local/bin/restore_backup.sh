#!/bin/sh

MODEL_NAME=`cat /proc/device-tree/model | cut -d - -f2`

cd /upload

if uudecode -o config.img $1 >/dev/null; then
  rm $1
  if update-tool --extract NTLR$MODEL_NAMEconf config.img > config.tar; then
    rm config.img

    mkdir -p /nvm/etc/backup_config
    cd /nvm/etc/backup_config

    tar xvf /upload/config.tar
  
    rm -rf /upload/*

    TARGET_DIR="/nvm/etc/config"                                                                                           
    SOURCE_DIR="/nvm_defaults/etc/config"                                                                                  
    CONFIGURATION_DEFS_PATH='/configuration_defaults'
    OPER_PATH='/etc/operators/default'

    echo ">>> Restoring factory defaults >>>"

    rm -rf $TARGET_DIR/*
    cp -rf $SOURCE_DIR/* $TARGET_DIR

    if [ -e /proc/device-tree/configuration ]; then                                                                        
          PROJECT_CONFIGURATION=$(cat /proc/device-tree/configuration); 

          cp -rfL $CONFIGURATION_DEFS_PATH/$PROJECT_CONFIGURATION/* /
    fi

    if [ -e $OPER_PATH ]; then              
        cp -rf $OPER_PATH/config/* $TARGET_DIR
        cp -rf $OPER_PATH/scripts/* /usr/local/bin/
        echo ">>> Copy Operator configurations for default operator >>>" > /dev/kmsg
    else                                                                     
        echo ">>> Error - path missing: $OPER_PATH >>>" > /dev/kmsg          
    fi                                                                       

    # restore wifi default config
    rm -rf /var/rtl8192c                                                                                                   
    /root/script/default_setting.sh wlan0 ap 
    /root/script/default_setting.sh wlan0-va0 ap

    /usr/local/bin/backup_config.sh uirestore
    /usr/local/bin/backup_config.sh restore

   echo Success
 else
   echo Fail
 fi
fi

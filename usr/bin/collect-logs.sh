#!/bin/sh
. /usr/local/bin/lte-gw-global-env.sh
TIME=$(date +%d_%m_%Y_%H_%M_%S)
FS_LOGS='/nvm'
TMP_PATH='/tmp/Logs'
ZIP_NAME='Logs_'$TIME
RUN_FILE=$TMP_PATH'/.collecting'
ARGC=$#
OPT=$1
CLEAR_PATH="0"
SYS_TYPE_1160=0

if [ -f $RUN_FILE ]; then
    echo "Error: collect-logs already running!"
    exit 1
fi

#check the system Type 1160
if [ $(cat /proc/cpuinfo | grep "system type" | grep "1160" -c ) -gt 0 ]; then
	SYS_TYPE_1160=1
	FS_LOGS=""
fi

if [ -e /proc/device-tree/config_type ]; then
    if [ $(cat /proc/device-tree/config_type) == "Sflash_nfs" ]; then
		FS_LOGS='/upload/nvm'
		mkdir -p $FS_LOGS
    fi
fi


if [ $ARGC -eq 1 ]
then
    if [ $OPT == "-c" ]
    then
        echo ">>> Crush dump! >>>" > /dev/kmsg
        ZIP_NAME='CrushDump_'$TIME
	PERM_SAVE_PATH=$FS_LOGS/CrushDumps

        if [ -d $PERM_SAVE_PATH ]
        then
            NUM_OF_DUMPS=$(ls $PERM_SAVE_PATH | wc -l)
            
            if [ "$NUM_OF_DUMPS" -gt "5" ]
            then
                echo ">>> Clear CrushDump folder... >>>"
                CLEAR_PATH="1"
            fi
        fi
    else
        echo "Error: option not supported!"
        exit 1
    fi
else 
    ZIP_NAME='Logs_'$TIME
    PERM_SAVE_PATH=$FS_LOGS/Logs
    CLEAR_PATH="1"
fi

TMP_SAVE_PATH=$TMP_PATH'/'$ZIP_NAME

if [ ! -d $TMP_PATH ]
then
   mkdir $TMP_PATH
fi

touch $RUN_FILE

# Remove the content of /tmp/Logs to prevent accumulation of Log_tar.gz files there
if [ -d $TMP_PATH ]
then
   rm -rf $TMP_PATH/*
fi

if [ ! -d $PERM_SAVE_PATH ]
then
   mkdir $PERM_SAVE_PATH
fi

if [ $CLEAR_PATH == "1" ]
then
    rm -rf $PERM_SAVE_PATH/*
fi

echo "************************************************************"
echo ">>> Saving log files into $PERM_SAVE_PATH ($ZIP_NAME.tar.gz) >>>"


make_symlinks () {
        local DIR=$1
        local PATTERN=$2
        local FILES=`ls $DIR | grep -e $PATTERN`

        for FILE in $FILES;
        do
		if [ -f $DIR/$FILE ]; then
			ln -s $DIR/$FILE $TMP_SAVE_PATH/$FILE
		fi
        done
}                                                                  

mkdir $TMP_SAVE_PATH

gzip /tmp/*.core 2> /dev/null #if core exists, compress it.

make_symlinks '/tmp' '\.log'
make_symlinks '/tmp' '\.pcap'
make_symlinks '/tmp' '\.gz'
if [ -d "/tmp/logs" ]; then
	make_symlinks '/tmp/logs' '\.log'
	make_symlinks '/tmp/logs' '\.pcap'
	make_symlinks '/tmp/logs' '\.gz'
fi

LOGS_MODE=`uci get lte-gw.modem_fw_logs.logs_mode`
if [ $LOGS_MODE == "internal" ] ; then
	make_symlinks '/tmp/ModemLog' '\.bin'
fi

make_symlinks '/tmp' '\.txt'
make_symlinks '/tmp' '^messages$\|^messages\..*$'
cp -rf /sys/devices/virtual/net/lte0/ue_fw_counters $TMP_SAVE_PATH
cp -rf /sys/devices/virtual/net/lte0/ue_fw_counters2 $TMP_SAVE_PATH

# Uboot
## Uboot BSP loading info
if [ -f "/proc/device-tree/uboot/uboot_missing_bsp" ]; then
    echo "=================================" > /tmp/uboot
    echo "U-Boot BSP loading missing files"  >> /tmp/uboot
    echo "=================================" >> /tmp/uboot
    echo -en "/proc/device-tree/uboot/uboot_missing_bsp: " >> /tmp/uboot
    cat /proc/device-tree/uboot/uboot_missing_bsp >> /tmp/uboot
fi

## Uboot environment
echo -en "\n\n=============================\n" >> /tmp/uboot
echo "U-Boot ENV (via fw_printenv)" >> /tmp/uboot
echo "=============================" >> /tmp/uboot
fw_printenv >> /tmp/uboot

mv -f /tmp/uboot $TMP_SAVE_PATH

#Generic tech support info
/usr/bin/tech-info.sh > /tmp/tech-info.log
cp -rf '/tmp/tech-info.log' $TMP_SAVE_PATH

#LTE GW spessifc tech support info
/usr/local/bin/lte-gw-show-tech.sh > /tmp/lte-gw.log
cp -rf '/tmp/lte-gw.log' $TMP_SAVE_PATH

#Generic sleep info
/usr/bin/sleep-info.sh > /tmp/sleep-info.log
cp -rf '/tmp/sleep-info.log' $TMP_SAVE_PATH

# Add bsp dop file
cp -rf '/nvm/bsp/dop' $TMP_SAVE_PATH

# Save bsp files cksum values
for entry in "/nvm/bsp/*"
do
    cksum $entry >> $TMP_SAVE_PATH/bsp_cksum.log
done

# Add ATSwitch configuration file
if [ -e /etc/atswitch_config/atswitch_ecm_config.csv ]; then
    cp -rf '/etc/atswitch_config/atswitch_ecm_config.csv' $TMP_SAVE_PATH
else
    if [ -e /tmp/printed_routing_tables ]; then
        cp -rf /tmp/printed_routing_tables $TMP_SAVE_PATH
        tar -cvhf $TMP_SAVE_PATH/atswitch_config.tar /etc/atswitch_config
    else
        echo "ERROR: cannot find atswitch config"
    fi
fi

# Add Ims xml configuration Related to the Log files.
# The xmls are in < Ims_conf_xml.tar > file.
if [ -d "/tmp/ims" ]; then
	tar -cvhf $TMP_SAVE_PATH/Ims_conf_xml.tar /tmp/ims/*
fi

# 161202, added dmesg logs
dmesg > /upload/dmesg.log
gzip /upload/dmesg.log
cp -rf '/upload/dmesg.log.gz' $TMP_SAVE_PATH
rm -rf /upload/dmesg.log*

# 190403, added Logs files
cp -rf /nvm/etc/Log* $TMP_SAVE_PATH

# 171207, added .ash_history
cp -rf '/.ash_history' $TMP_SAVE_PATH

#special treatment for PWRT or WRT:
if ([ $PROJECT_TYPE == "WRT" ] || [ $PROJECT_TYPE == "PWRT" ]); then
    if [ -f "/usr/bin/wifi-info.sh" ]; then
       /usr/bin/wifi-info.sh > /tmp/wifi-info.log 
       cp -rf '/tmp/wifi-info.log' $TMP_SAVE_PATH
    fi
fi

# Add dnsmasq config files
cp -rf '/etc/dnsmasq-mng.conf' $TMP_SAVE_PATH
cp -rf '/etc/dnsmasq.conf' $TMP_SAVE_PATH

cd $TMP_PATH
tar -cvhf $ZIP_NAME'.tar' $ZIP_NAME
rm -rf $TMP_SAVE_PATH
gzip $ZIP_NAME'.tar'

#check if there is enough space to copy file
#if there is not then empty logs from nvm and try again
# in any case do not try to copy file which its size is bigger than the free space in nvm to nvm
copy_allowed='false'
let sz=`ls $ZIP_NAME'.tar.gz' -l | awk '{ print $5 }'`
let sz=sz/1000
#echo "FILE SIZE: $sz"
let free_sz=`df -k | grep nvm | awk  '{ print $4 }'`
#echo "FREE SZ: $free_sz"
let size_after_copy=free_sz-sz
if [ $size_after_copy -gt 100 ]; then
   echo "enough place for new log ($size_after_copy)"
   copy_allowed='true'
else
   echo ">>> missing place for new log - log size $sz missing size $size_after_copy -  going to free space in /nvm"
   rm -rf $FS_LOGS/CrushDumps/*
#   rm -rf $FS_LOGS/Logs/*
if [ $SYS_TYPE_1160 -eq 1 ]; then
	free_sz=`df -k | grep dev/root | awk  '{ print $4 }'`	   		
else
	free_sz=`df -k | grep nvm | awk  '{ print $4 }'`
fi
   echo ">>> free space after cleaning : $free_sz"
   let size_after_copy=free_sz-sz
   if [ $size_after_copy -lt 100 ]; then
      echo ">>> Error - logs collection failed (no place to save log file with size $sz when nvm has only $free_sz free space>>>"
   else
    copy_allowed='true'
   fi      
fi



if [ $copy_allowed == 'true' ]; then
	mv $ZIP_NAME'.tar.gz' $PERM_SAVE_PATH
	sync
	RETVAL=$?

	if [ $RETVAL -ne 0 ]; then
	    rm -rf $PERM_SAVE_PATH/*
	    rm -rf $TMP_PATH/*
	    echo ">>> Error - logs collection failed >>>"
	fi
fi

rm -rf $RUN_FILE

echo "************************************************************"


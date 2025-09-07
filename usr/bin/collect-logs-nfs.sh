#!/bin/sh

TIME=$(date +%d_%m_%Y_%H_%M_%S)
TMP_PATH='/tmp/Logs'
ZIP_NAME='Logs_'$TIME
TMP_SAVE_PATH=$TMP_PATH'/'$ZIP_NAME
PERM_SAVE_PATH=`uci get alt-vdmc.Config.DlDirectory`

show_usage()
{
  echo "collect-logs-nfs.sh <IP address of NFS server> <remote directory>"
  exit 1
}

if [ $# -ne 2 ]; then
  show_usage
fi

echo "************************************************************"
echo ">>> Saving log files into $PERM_SAVE_PATH ($ZIP_NAME) >>>"

if [ ! -d $TMP_PATH ]
then
   mkdir $TMP_PATH
fi

#----------------- NFS mount ----------------------------
nfs-mount.sh $1 $2
#--------------------------------------------------------

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

make_symlinks '/tmp' '\.log'

LOGS_MODE=`uci get lte-gw.modem_fw_logs.logs_mode`
if [ $LOGS_MODE == "internal" ] ; then
	make_symlinks '/tmp/ModemLog' '\.bin'
fi

make_symlinks '/tmp' '\.txt'
make_symlinks '/tmp' '^messages$\|^messages\..*$'
if [ -d "/tmp/logs" ]; then
	make_symlinks '/tmp/logs' '\.txt'
	make_symlinks '/tmp/logs' '^messages$\|^messages\..*$'
fi

cp -rf /sys/devices/virtual/net/lte0/ue_fw_counters $TMP_SAVE_PATH
cp -rf /sys/devices/virtual/net/lte0/ue_fw_counters2 $TMP_SAVE_PATH

# Uboot environment
fw_printenv > /tmp/uboot_env                                                    
cp -rf /tmp/uboot_env $TMP_SAVE_PATH

#Generic tech support info
if [ -f "/usr/bin/tech-info.sh" ]; then
    /usr/bin/tech-info.sh > /tmp/tech-info.log
    cp -rf '/tmp/tech-info.log' $TMP_SAVE_PATH
fi

#LTE GW spessifc tech support info
if [ -f "/usr/local/bin/lte-gw-show-tech.sh" ]; then
    /usr/local/bin/lte-gw-show-tech.sh > /tmp/lte-gw.log
    cp -rf '/tmp/lte-gw.log' $TMP_SAVE_PATH
fi

#Generic sleep info
if [ -f "/usr/bin/sleep-info.sh" ]; then
    /usr/bin/sleep-info.sh > /tmp/sleep-info.log
    cp -rf '/tmp/sleep-info.log' $TMP_SAVE_PATH
fi

# Add ATSwitch configuration file
cp -rf '/etc/atswitch_config/atswitch_ecm_config.csv' $TMP_SAVE_PATH

# Add bsp dop file
cp -rf '/nvm/bsp/dop' $TMP_SAVE_PATH

# Save bsp files cksum values
for entry in "/nvm/bsp/*"
do
    cksum $entry >> $TMP_SAVE_PATH/bsp_cksum.log
done


cd $TMP_PATH                                                                       
tar -cvhf $ZIP_NAME'.tar' $ZIP_NAME                                              
gzip $ZIP_NAME'.tar'                                                            
rm -rf $TMP_SAVE_PATH

mv $ZIP_NAME'.tar.gz' $PERM_SAVE_PATH

#----------------- NFS unmount -------------------
nfs-umount.sh
echo "************************************************************"


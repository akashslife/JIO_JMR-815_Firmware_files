#!/bin/sh

UPDATE_FILE=$1

HAVE_MIXED_FILE=0
HAVE_UBOOT=0
HAVE_DEVICE_TREE=0
HAVE_MODEM_FW=0
#jclee,150209, NTmore firmware check
HAVE_NTMORE_FW=0
SWITCH_PARTITION_ENABLE=0
MANUAL_BOOT_NUMBER_ENABLE=0
BOOT_NUMBER=0

usage() {
    echo ""
    echo "usage: $(basename $0)"
    echo "  <fwu.img>"
    echo "  option:"
#    echo "    -d <device tree (.dtb)>"
    echo "    -u <u-boot image (.bin)>"
    echo "    -f <modem firmware (.lzo)>"
    echo "    -b <defines the boot number (1 or 2)>"
}
#150209, jclee, for fwu.img model name separator.
MODEL_NAME=`cat /proc/device-tree/model | cut -d - -f2`

parse_args() {
	local ARGC=$#
	
	if [ $ARGC -eq 1 ]; then
		# check if there is update file
		if [ -e $1 ]
		then
			UPDATE_FILE=$1
			HAVE_MIXED_FILE=1
			SWITCH_PARTITION_ENABLE=1
		else
			echo "!!! Update file not found!"
			usage
			exit 1
		fi
    elif [ $ARGC -gt 1 ]; then
        local CONFLICT_OPTS=0
	    
        while [[ $# -gt 1 ]]
        do
            OPT="$1"
            shift
            
            case $OPT in
                -d) # DEVICE TREE option
                    UPDATE_FILE=$1
                    shift
                    if [ "${UPDATE_FILE##*.}" = "dtb" ]; then
                        HAVE_DEVICE_TREE=1
                        CONFLICT_OPTS=`expr $CONFLICT_OPTS + 1`
                    else
                        echo "!!! Invalid format of update file!"
                        exit 1
                    fi
                    ;;

                -u) # U-BOOT option
                    UPDATE_FILE=$1
                    shift
                    if [ "${UPDATE_FILE##*.}" = "bin" ]; then
                        HAVE_UBOOT=1
                        CONFLICT_OPTS=`expr $CONFLICT_OPTS + 1`
                    else
                        echo "!!! Invalid format of update file!"
                        exit 1
                    fi
                    ;;

                -f) # MODEM FIRMWARE option
                    UPDATE_FILE=$1
                    shift
                    if [ "${UPDATE_FILE##*.}" = "lzo" ]; then
                        HAVE_MODEM_FW=1
                        CONFLICT_OPTS=`expr $CONFLICT_OPTS + 1`
                    else
                        echo "!!! Invalid format of update file!"
                        exit 1
                    fi
                    ;;

                -b) # BOOT NUMBER option
                    BOOT_NUMBER=$1
                    shift
                    if [ $BOOT_NUMBER == '1' ] || [ $BOOT_NUMBER == '2' ]; then
                        MANUAL_BOOT_NUMBER_ENABLE=1
                    else
                        echo "!!! Invalid a boot number!"
                        exit 1
                    fi
                    ;;

                *) # UNKNOWN option
                    echo "!!! Option not supported!"
                    usage 
                    exit 1
                    ;;
            esac
        done
        
        if [ $CONFLICT_OPTS -gt 1 ]; then
            echo "!!! Multi-option mode not supported!"            
            usage 
            exit 1
        fi
	else
		echo "!!! Update file not found!"
		usage
		exit 1
	fi
}

is_alt3100_arch() {
    local SYSTEM_TYPE=`cat /proc/cpuinfo | grep 'system type' | cut -d ":" -f 2`
    if [ $SYSTEM_TYPE == "ALT3100" ]
    then
        echo '1'
    else
        echo '0'
    fi
}

get_opt() {
        echo "$@" | cut -d "=" -f 2
}
HAVE_MIXED_FILE=0
HAVE_UBOOT=0
HAVE_DEVICE_TREE=0
HAVE_MODEM_FW=0

# $1 - KERNEL_DEVICE
# $2 - CHUNK_NAME
# $3 - UPDATE_FILE
flash_partition() {
    echo "*** Erasing $2..."
    if flash_erase /dev/$1 0 0 > /dev/null; then
        echo "OK!"
    else
        echo "!!! Failed to erase $2!"
        exit 1
    fi

    echo "*** Flashing $2..."
    set -o pipefail
    update-tool --extract $2 $3 | nandwrite -p /dev/$1 - > /dev/null
    if [ $? = "0" ]; then
        echo "OK!"
    else
        echo "!!! Failed to flash $2!"
        exit 1
    fi
}

check_partition() {
                    
    echo "*** Checking $1..."         
    update-tool --extract $1 $2 > /dev/null
    if [ $? = "0" ]; then	
        echo "OK!"                               
    else            
        echo "!!! Failed to check $1!"                   
        exit 1               
    fi                        
}

# Get index of MTD block 
get_mtd_block() {
    local MTD_BLOCK=`cat /proc/mtd | grep "\"$1\"$" | cut -d: -f1`

    if [ -e $MTD_BLOCK ]; then
        echo '-1'
        exit 1
    fi
	
    echo $MTD_BLOCK
}

# Burn partition from file
flash_partition_from_file() {
    local MTD_BLOCK=$(get_mtd_block $1)
    local MTD_DESC=$2
    local IMAGE_FILE=$3
    local MTD_DEVICE=/dev/$MTD_BLOCK

    if [ "$MTD_BLOCK" == '-1' ]; then
        echo "!!! Failed to find the $1 partition"
        exit 1
    fi

    local FILE_SIZE=$(ls -n $IMAGE_FILE | awk '{print $5}')
            
    local MTD_BLOCK_SIZE=$((0x$(cat /proc/mtd | grep $MTD_BLOCK":" | awk '{print $2}')))
                    
    # check if file size fits the MTD (flash paratition) size
    if [[ $FILE_SIZE -gt $MTD_BLOCK_SIZE ]]; then
        echo "Error! image $IMAGE_FILE for $MTD_DESC is larger then target device $MTD_BLOCK"
        echo "Aborting upgrade!"
        exit 1
    fi 

    # erase the partition
    echo "*** Erasing $MTD_DESC..."
    if flash_erase $MTD_DEVICE 0 0 > /dev/null; then
        echo "OK!"
    else
        echo "!!! Failed to erase the $MTD_DESC!"
        exit 1
    fi
        
    # write to flash
    echo "*** Flashing $MTD_DESC..."
    if nandwrite -p $MTD_DEVICE "$IMAGE_FILE"> /dev/null; then
        echo "OK!"
    else
        echo "!!! Failed to flash the $MTD_DESC!"
        exit 1
    fi
}

# Erase partition
erase_partition() {
    local MTD_BLOCK=$(get_mtd_block $1)
    local MTD_DESC=$1
    local MTD_DEVICE=/dev/$MTD_BLOCK	

    if [ "$MTD_BLOCK" == '-1' ]; then
        echo "!!! Failed to find the $1 partition"
        exit 1
    fi

    # erase the partition
    echo "*** Erasing $MTD_DESC..."
    if flash_erase $MTD_DEVICE 0 0 > /dev/null; then
        echo "OK!"
    else
        echo "!!! Failed to erase the $MTD_DESC!"
        exit 1
    fi
}
# ntmore added, for FOTA binary.
/usr/bin/fw_header_tool $1

# Parse the cmdline arguments
parse_args $1 $2 $3 $4 

# Get the current boot number
if [ $MANUAL_BOOT_NUMBER_ENABLE == '0' ]; then
    UBOOT_ENV_VAR=`fw_printenv boot_number`
    if [ ! -e $UBOOT_ENV_VAR ]; then
        BOOT_NUMBER=$(get_opt $UBOOT_ENV_VAR)
    else
        echo "!!! Failed to detect the boot_number!"
        exit 1
    fi
fi

if [ $SWITCH_PARTITION_ENABLE == '1' ]; then
    echo "*** Current boot_number #$BOOT_NUMBER"

    if [ $BOOT_NUMBER == '1' ]; then
        BOOT_NUMBER=2
    else
        BOOT_NUMBER=1
    fi
fi

if [ $HAVE_MIXED_FILE == '1' ]; then
    local HAVE_KERNEL=0
    local HAVE_ROOTFS=0
    local HAVE_MODEM_FW=0
    local HAVE_DEVICE_TREE=0

    echo "*** Looking for kernel..."
    if [ $(update-tool --list $UPDATE_FILE | grep -c kernel) -ne 0 ]; then
        echo "*** Kernel found"
        check_partition kernel $UPDATE_FILE
        HAVE_KERNEL=1
    fi

    echo "*** Looking for rootfs..."
    if [ $(update-tool --list $UPDATE_FILE | grep -c rootfs) -ne 0 ]; then
        echo "*** Rootfs found"
        check_partition rootfs $UPDATE_FILE
        HAVE_ROOTFS=1
    fi

    echo "*** Looking for lte modem firmware..."
    if [ $(update-tool --list $UPDATE_FILE | grep -c modem_fw) -ne 0 ]; then
        echo "*** modem lte firmware found"
        check_partition modem_fw $UPDATE_FILE
        HAVE_MODEM_FW=1
    fi

#150209, jclee, NTmore added NTmore Firmware [START]
	echo "*** Looking for NTmore firmware..."
    if [ $(update-tool --list $UPDATE_FILE | grep -v "factory" | grep -c ntlr$MODEL_NAME) -ne 0 ]; then
		echo "*** ntmore firware found"
        check_partition ntlr$MODEL_NAME $UPDATE_FILE
		HAVE_NTMORE_FW=1
	fi
#150209, jclee, NTmore added NTmore Firmware [END]

#150209, jclee, NTmore added device tree [START]
	echo "*** Looking for Device tree..."
    if [ $(update-tool --list $UPDATE_FILE | grep -c device_tree) -ne 0 ]; then
		echo "*** ntmore firware found"
        check_partition device_tree $UPDATE_FILE		
		HAVE_DEVICE_TREE=1
	fi
#150209, jclee, NTmore added device tree [END]


    if [ $HAVE_ROOTFS == '0' ] || [ $HAVE_KERNEL == '0' ] || [ $HAVE_MODEM_FW == '0' ] || [ $HAVE_NTMORE_FW == '0' ] || [ $HAVE_DEVICE_TREE == '0' ]; then
        echo "*** Invalid file or file not found"
		rm $UPDATE_FILE
		SWITCH_PARTITION_ENABLE=0
        exit 1
    else

#150209, jclee, backup config [START]
		/usr/local/bin/backup_config.sh backup
#150209, jclee, backup config [END]

		sync
	fi

    /usr/local/bin/update_led.sh &
    KERNEL_DEVICE=$(cat /proc/mtd | grep kernel$BOOT_NUMBER | cut -d: -f1)
    ROOTFS_DEVICE=$(cat /proc/mtd | grep rootfs$BOOT_NUMBER | cut -d: -f1)
    MODEM_FW_DEVICE=$(cat /proc/mtd | grep fw$BOOT_NUMBER | cut -d: -f1)
    DTB_DEVICE=$(cat /proc/mtd | grep dtb$BOOT_NUMBER | cut -d: -f1)

    if [ $HAVE_KERNEL == '1' ]; then
        flash_partition $KERNEL_DEVICE kernel $UPDATE_FILE
    fi

    if [ $HAVE_ROOTFS == '1' ]; then
        flash_partition $ROOTFS_DEVICE rootfs $UPDATE_FILE
    fi

    if [ $HAVE_MODEM_FW == '1' ]; then
        # check if partition is exist
        if [ -n "$MODEM_FW_DEVICE" ]; then 
            flash_partition $MODEM_FW_DEVICE modem_fw $UPDATE_FILE
        fi
    fi
	
    if [ $HAVE_DEVICE_TREE == '1' ]; then
        if [ -n "$DTB_DEVICE" ]; then 
			flash_partition $DTB_DEVICE device_tree $UPDATE_FILE
		fi
	fi
fi

    #jclee, run extra command
    if [ $(update-tool --list $UPDATE_FILE | grep -c command) -ne 0 ]; then
	update-tool --extract command $UPDATE_FILE > /upload/update_command.sh
	chmod a+x /upload/update_command.sh	
    fi

    #20150713, jclee, update bootloader
    if [ $(update-tool --list $UPDATE_FILE | grep -c uboot) -ne 0 ]; then
	update-tool --extract uboot $UPDATE_FILE >/upload/u-boot.bin
	local MTD_NAMES='uboot1 uboot2'

	for MTD_NAME in $MTD_NAMES
	do
        	flash_partition_from_file $MTD_NAME $MTD_NAME /upload/u-boot.bin
			sync
	done

	erase_partition 'env'
	erase_partition 'backup_env'

	rm -rf /upload/u-boot.bin
	sync

    fi

#elif [ $HAVE_UBOOT == '1' ]; then
#    local MTD_NAMES='uboot1 uboot2'
#
#    if [ "$(is_alt3100_arch)" == '1' ]
#    then
#        MTD_NAMES='u-boot u-boot2'
#    fi
#	
#    for MTD_NAME in $MTD_NAMES
#    do
#        flash_partition_from_file $MTD_NAME $MTD_NAME $UPDATE_FILE
#    done
#
#    erase_partition 'env'
#    erase_partition 'backup_env'

#    echo ""
#    echo "*******************************************************************************"
#    echo "* IMPORTANT: This operation REQUIRES reboot the system. The boot environments *"
#    echo "*            are erased therefore boot_number value will set to 1.            *"
#    echo "*******************************************************************************"
#    echo ""
#elif [ $HAVE_DEVICE_TREE == '1' ]; then
#    flash_partition_from_file "dtb$BOOT_NUMBER" device_tree $UPDATE_FILE
#elif [ $HAVE_MODEM_FW == '1' ]; then
#    flash_partition_from_file "modem_fw$BOOT_NUMBER" modem_fw $UPDATE_FILE
#fi

if [ $SWITCH_PARTITION_ENABLE == '1' ]; then
    echo "*** Will switch to boot_number #$BOOT_NUMBER"
    echo "*** Done, switching to new system!"
    fw_setenv boot_number $BOOT_NUMBER
#150209,jclee, jwpark 2014.04.02 TR69 : 4 CHANGE VALUE after F/W update
	touch /nvm/tr069_fw_update
	sh /upload/update_command.sh	
	fw_setenv bootdelay 0
	fw_setenv en_usb_on_init
	fw_setenv reboot 1
	sync
else
    echo "*** Done"
fi

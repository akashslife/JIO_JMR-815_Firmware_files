#!/bin/sh

UPDATE_FILE=$1

get_opt() {
        echo "$@" | cut -d "=" -f 2
}

if [ ! -e $UPDATE_FILE ]; then
	echo "!!! Update file not found!"
	exit 1
fi

HAVE_KERNEL=0
HAVE_ROOTFS=0
BOOT_NUMBER=1

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
	if update-tool --extract $2 $3 | nandwrite -p /dev/$1 - > /dev/null; then
		echo "OK!"
	else
		echo "!!! Failed to flash $2!"
		exit 1
	fi
}

# Process kernel command line options
for i in $(cat /proc/cmdline); do
        case $i in
                boot_number\=*)
                              BOOT_NUMBER=$(get_opt $i)
                              ;;
        esac
done

echo "*** Current boot_number #$BOOT_NUMBER"

if [ $BOOT_NUMBER == '1' ]; then
	BOOT_NUMBER=2
else
	BOOT_NUMBER=1
fi

echo "*** Will update boot_number #$BOOT_NUMBER"

echo "*** Looking for kernel..."
if update-tool --extract kernel $UPDATE_FILE >/dev/null ; then
	echo "*** Kernel found"
	HAVE_KERNEL=1
fi

echo "*** Looking for rootfs..."
if update-tool --extract rootfs $UPDATE_FILE >/dev/null ; then
	echo "*** Rootfs found"
	HAVE_ROOTFS=1
fi

if [ $HAVE_ROOTFS == '0' ] && [ $HAVE_KERNEL == '0' ]; then
	echo "!!! Update is empty!"
	exit 1
fi

KERNEL_DEVICE=$(cat /proc/mtd | grep kernel$BOOT_NUMBER | cut -d: -f1)
ROOTFS_DEVICE=$(cat /proc/mtd | grep rootfs$BOOT_NUMBER | cut -d: -f1)

if [ $HAVE_KERNEL == '1' ]; then
	flash_partition $KERNEL_DEVICE kernel $UPDATE_FILE
fi

if [ $HAVE_ROOTFS == '1' ]; then
	flash_partition $ROOTFS_DEVICE rootfs $UPDATE_FILE
fi

echo "*** Done! ***"


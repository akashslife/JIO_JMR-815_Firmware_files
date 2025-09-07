#!/bin/sh

fw_file=`uci get lte.config.firmware`
echo "hotplug.sh: param $*" >> /tmp/log.txt
env >> /tmp/log.txt
if [ "firmware" != $1 ] ; then
  echo Wrong firmware: $1
  exit 0
fi
if [ $fw_file == "null" ] ; then
  boot_number=$(fw_printenv boot_number | sed 's/[^0-9]*\([0-9]*\).*/\1/')
  fw_file=$(cat /proc/mtd | grep modem_fw$boot_number | cut -d: -f1 | sed -e 's/mtd/\/dev\/mtdblock/')
  echo "hotplug.sh: using active partition boot_number=$boot_number" > /dev/kmsg
fi
echo "hotplug.sh: fw_file=$fw_file" > /dev/kmsg
echo "entering hotplug.sh" >> /tmp/log.txt 
echo 1 > /sys/${DEVPATH}/loading
cat ${fw_file} > /sys/${DEVPATH}/data
echo 0 > /sys/${DEVPATH}/loading

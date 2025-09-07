#! /bin/sh
echo "-----------------------------"
echo "config script:"
cat /etc/config/wifi_init_config
echo "-----------------------------"
NEW_STR=""
while read line; do
	echo $line | sed 's/[^\;]*$//'
	NEW_STR=$NEW_STR`echo $line | sed 's/[^\;]*$//'`
done < /etc/config/wifi_init_config
echo "-----------------------------"
echo $NEW_STR
UBOOT_STR=`fw_printenv | grep prebootcmd=`
echo "UBOOT="$UBOOT_STR
UBOOT_STR=`echo $UBOOT_STR | sed 's/^.*=//'`
echo "UBOOT="$UBOOT_STR
if [ "$UBOOT_STR" == "$NEW_STR" ]; then
	echo "EQ"
	echo $UBOOT_STR
	echo $NEW_STR
else
	echo "NEQ"
	echo $UBOOT_STR
	echo ${#UBOOT_STR}
	echo $NEW_STR
	echo ${#NEW_STR}
	echo "-----------------------------"
        fw_setenv prebootcmd `echo $NEW_STR`
fi

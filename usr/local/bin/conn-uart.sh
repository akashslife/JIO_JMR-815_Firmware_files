enable()
{

fw_setenv bootdelay 0
fw_setenv consoledev /dev/null
echo "/bin/stty -F /dev/ttyS0 115200" >/etc/init.d/S02serial-at
echo "fw_setenv reboot 1">>/etc/init.d/S02serial-at
echo "sync">>/etc/init.d/S02serial-at
chmod a+x /etc/init.d/S02serial-at
cp /etc/ue_lte/relayAT.sh /etc/ue_lte/relayAT.sh.org
sed -i -e "/UNIX-CONNECT/d" /etc/ue_lte/relayAT.sh
sed -i -e "8 i\   socat -d -d /tmp/atsw0 /dev/ttyS0,nonblock" /etc/ue_lte/relayAT.sh
sync

reboot

}

disable()
{
if [ -f /etc/init.d/S02serial-at ];then
	rm /etc/init.d/S02serial-at
fi

if [ -f /etc/ue_lte/relayAT.sh.org ];then
	mv /etc/ue_lte/relayAT.sh.org /etc/ue_lte/relayAT.sh
fi
fw_setenv consoledev ttyS0
fw_setenv bootdelay 0
sync

reboot


}


case "$1" in
    enable)
                echo "ttyS0 for ATcommand enabled...reboot device"
	        enable
        ;;

    disable)
                echo "ttyS0 for ATcommand disabled...reboot device"
                disable
                ;;
    status)
		if [ -f /etc/ue_lte/relayAT.sh.org];then
			echo "enable ttyS0 for AT command"
		else
			echo "disable ttyS0 for AT command"
		fi
		;;
    *)
        echo "Usage: $0 {enable|disable|status}"
        exit 1
esac


#!/bin/sh
echo "==============="
echo "Version"
echo "==============="
cat /etc/config/version

echo "==============="
echo "Altair Version"
echo "==============="
cat /etc/ecm/.org_version

echo "==============="
echo "date -R"
echo "==============="
date -R

if [ -e /proc/device-tree/configuration ]; then
    echo "=================="
    echo "DTB configuration"
    echo "=================="
    cat /proc/device-tree/configuration
    echo ""
fi

if [ -e /usr/bin/opkg ]; then
    echo "=================="
    echo "Installed Packages"
    echo "=================="
    /usr/bin/opkg info
    echo ""
fi

echo "================"
echo "Bands in bandbp"
echo "================"
cat /nvm/bsp/bandbp
echo ""

echo "===================="
echo "BSP files in bandbp"
echo "===================="
cat /nvm/bsp/bspfilesbp
echo ""

echo "==============="
echo "uptime"
echo "==============="
uptime

echo "==============="
echo "ps"
echo "==============="
ps

echo "==============="
echo "top"
echo "==============="
top -b -n 1

echo "==============="
echo "netstat"
echo "==============="
netstat -na

echo "==============="
echo "lsmod"
echo "==============="
lsmod

echo "==============="
echo "ifconfig"
echo "==============="
ifconfig

echo "==============="
echo "Conntrack count"
echo "==============="
conntrack -C

if [ -f /etc/resolv.conf ]
then
        echo "==============="
	echo "resolv.conf"
	echo "==============="
	cat /etc/resolv.conf
fi

if [ -f /tmp/resolv.dnsmasq.conf ]
then
        echo "==============="
	echo "resolv.dnsmasq.conf"
	echo "==============="
	cat /tmp/resolv.dnsmasq.conf
fi

if [ -f /tmp/dnsmasq.leases ]
then
        echo "==============="
        echo "dnsmasq.leases"
        echo "==============="
        cat /tmp/dnsmasq.leases
fi

if [ -f /tmp/dhclient.lease ]
then
        echo "==============="
        echo "dhclient.lease"
        echo "==============="
        cat /tmp/dhclient.lease
fi

if [ -f /tmp/dhcpd.conf ]
then
        echo "==============="
        echo "dhcpd.conf"
        echo "==============="
        cat /tmp/dhcpd.conf
fi

if [ -f /tmp/map-t.opt ]
then
        echo "==============="
        echo "map-t.opt"
        echo "==============="
        cat /tmp/map-t.opt
fi


for f in `find /etc/config/ -maxdepth 1 -type f` `find /etc/static-config/ -maxdepth 1 -type f`
do
   uci show $f -q > /tmp/t_uci
   if [ "$(cat /tmp/t_uci)" ] ; then
    echo     "=========================="
    echo "show $f"
    echo     "=========================="
    cat /tmp/t_uci
    echo -e  "\n"
   fi
done
rm /tmp/t_uci

echo "==============="
echo "db -d"
echo "==============="
db -d

echo "==============="
echo "cpuinfo"
echo "==============="
cat /proc/cpuinfo

echo "==============="
echo "meminfo"
echo "==============="
cat /proc/meminfo

echo "==============="
echo "/tmp directory:"
echo "==============="
du /tmp -h
echo
du /tmp/* -h | awk '{ if($1 > 0) print $1 " -- " $2 }'
du /tmp/logs/* -h | awk '{ if($1 > 0) print "  " $1 " -- " $2 }'

echo "==============="
echo "df"
echo "==============="
df

echo "==============="
echo "dmesg"
echo "==============="
dmesg 


echo "               "
echo "==============="
#SHM_DRV_ADDR=$(hexdump /proc/device-tree/soc/shmnet@1/reg | awk -F' ' '{print$2$3}' | head -n 1)
#cat /sys/devices/soc.0/$SHM_DRV_ADDR.shmnet/shm_net_internal


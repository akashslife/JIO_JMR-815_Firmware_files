#!/bin/sh
 
# ALT3100_PWRT_03_00_04_00_14 : Change the "First PDN Device" : lte0 -> lte0.1
#LTE_INTERFACE="lte0"
INTERNET_INTERACE_FILE='/tmp/internet_if.txt'
LTE_INTERFACE=`cat $INTERNET_INTERACE_FILE`

sleep 2

if [ ! -f /tmp/wan ]; then
	cp /nvm_defaults/etc/config/wan /tmp/wan
fi

case "$1" in
	deconfig)
	uci set /tmp/wan.status.wan_connection_up_time=''
	uci set /tmp/wan.status.ipv4_addr=''
	uci set /tmp/wan.status.ipv4_subnetmask=''
	uci set /tmp/wan.status.ipv4_default_gw=''
#	uci set /tmp/wan.status.ipv4_pri_dns=''
#	uci set /tmp/wan.status.ipv4_sec_dns=''
	uci set /tmp/wan.status.ipv6_addr_link=''
	uci set /tmp/wan.status.ipv6_addr_link_ip=''
	uci set /tmp/wan.status.ipv6_addr_link_prefix=''
	uci set /tmp/wan.status.ipv6_addr_global=''
	uci set /tmp/wan.status.ipv6_addr_global_ip=''
	uci set /tmp/wan.status.ipv6_addr_global_prefix=''
	uci set /tmp/wan.status.ipv6_gw=''
#	uci set /tmp/wan.status.ipv6_pri_dns=''
#	uci set /tmp/wan.status.ipv6_sec_dns=''
	uci commit /tmp/wan
	;;
	
	renew|bound)
	ipv4_addr=`ifconfig $LTE_INTERFACE | grep "inet addr" | awk '{print $2}' | cut -d : -f 2`
	ipv4_subnetmask=`ifconfig $LTE_INTERFACE | grep "inet addr" | awk '{print $3}' | cut -d : -f 2`
	ipv4_default_gw=`route -n | grep UG | awk '{print $2}'`

# 타이밍 이슈 발생
# 1. wan-status.sh에서 /etc/resolv.dnsmasq.conf 읽음 (아직 파일 내용 없음)
# 2. nameserver-conf.sh에서 /etc/resolv.dnsmasq.conf 파일 작성
# 3. nameserver-conf.sh에서 'ipv4_pri_dns' 및 'ipv4_sec_dns'에 정상적인 값 설정
# 4. wan-status.sh에서 1번에서 읽은 빈 값을 다시 설정함
# 5. 주로 manual로 접속을 끊었다가 연결할 시 발생 함
# 6. nameserver-conf.sh에서만 설정하는 것으로 수정 (이 Shell에서는 기능 막음)
#	ipv4_pri_dns=`cat /etc/resolv.dnsmasq.conf | grep nameserver | head -n 1 |awk '{print $2}'`

#	if [ `grep -c "nameserver" /etc/resolv.dnsmasq.conf` -eq 2 ];then                          
#		ipv4_sec_dns=`cat /etc/resolv.dnsmasq.conf | grep nameserver | tail -n 1 |awk '{print $2}'`
#	fi

	ipv6_addr_link=`ifconfig $LTE_INTERFACE | grep inet6 | grep Link | awk '{print $3}'| head -n 1`
	ipv6_addr_link_ip=`ifconfig $LTE_INTERFACE | grep inet6 | grep Link | awk '{print $3}'| head -n 1 | cut -d / -f1`
	ipv6_addr_link_prefix=`ifconfig $LTE_INTERFACE | grep inet6 | grep Link | awk '{print $3}'| head -n 1 | cut -d / -f2`
	ipv6_addr_global=`ifconfig $LTE_INTERFACE | grep inet6 | grep Global | awk '{print $3}'| head -n 1`
	ipv6_addr_global_ip=`ifconfig $LTE_INTERFACE | grep inet6 | grep Global | awk '{print $3}'| head -n 1 | cut -d / -f1`
	ipv6_addr_global_prefix=`ifconfig $LTE_INTERFACE | grep inet6 | grep Global | awk '{print $3}'| head -n 1 | cut -d / -f2`
	ipv6_gw=`route -A inet6 | grep -w "UG" | awk '{print $2}'|uniq`

	if [ `echo $ipv6_gw | wc -L` -eq 0 ];then
		ipv6_gw=`route -A inet6 | grep "UG" | awk '{print $2}'|uniq`
	fi

	uci set /tmp/wan.status.ipv4_addr="$ipv4_addr"	
	uci set /tmp/wan.status.ipv4_subnetmask="$ipv4_subnetmask"
	uci set /tmp/wan.status.ipv4_default_gw="$ipv4_default_gw"
#	uci set /tmp/wan.status.ipv4_pri_dns="$ipv4_pri_dns"
#	uci set /tmp/wan.status.ipv4_sec_dns="$ipv4_sec_dns"
	uci set /tmp/wan.status.ipv6_addr_link="$ipv6_addr_link"
	uci set /tmp/wan.status.ipv6_addr_link_ip="$ipv6_addr_link_ip"
	uci set /tmp/wan.status.ipv6_addr_link_prefix="$ipv6_addr_link_prefix"
	uci set /tmp/wan.status.ipv6_addr_global="$ipv6_addr_global"
	uci set /tmp/wan.status.ipv6_addr_global_ip="$ipv6_addr_global_ip"
	uci set /tmp/wan.status.ipv6_addr_global_prefix="$ipv6_addr_global_prefix"
	uci set /tmp/wan.status.ipv6_gw="$ipv6_gw"
	uci commit /tmp/wan
	;;
esac

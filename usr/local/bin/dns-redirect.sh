#!/bin/sh

# second instance of dnsmasq, handles dns requiests and replies with
# one IP address for all redirects (should be used when LTE is down)
# it uses the same interface as being used by main isntance of dnsmasq


DNS_INT=`sed -n -e 's/^.*interface=\(.*\)$/\1/p' /etc/dnsmasq.conf`
LOCAL_DNS_PORT=5553


print_usage() {
    echo    'Usage: $0 (enable|disable)     -- enable (or disable) redirect of all DNS queries to the local address'
    exit 0
}


get_local_addr() {
    # uci get lte-gw.local_param.local_ip_addr
    ip addr show dev $DNS_INT scope global primary | sed -n  -e "/inet/s/^[^0-9]*\([0-9.]\+\).*/\1/p"
}


start_dns_redirect() {
    local LOCAL_IP=`get_local_addr`

    dnsmasq --pid-file=/var/run/dnsmasq.redirect.pid    \
        -I $DNS_INT                                     \
        --address="/altair.honeynut/$LOCAL_IP"          \
        --address="/#/$LOCAL_IP"                        \
        -p $LOCAL_DNS_PORT                              \
        --no-dhcp-interface=$DNS_INT                    \
        --listen-address=$LOCAL_IP
}


stop_dns_redirect() {
    kill "`cat /var/run/dnsmasq.redirect.pid`"
}


################################################################


if [ $# -le 0 ]; then
    print_usage
fi

if [ "x$DNS_INT" == "x" ]; then
    echo Unable to determine default interface for dnsmasq. Check /etc/dnsmasq.conf 1>&2
    exit 1
fi

if [ $# == 1 ]; then
    case $1 in

        enable)
            start_dns_redirect
            # remove old rules in case we try to enable redirects twice to avoid having duplicate rules
            iptables -t nat -D PREROUTING -i $DNS_INT -p tcp --dport 53 -j REDIRECT --to-ports $LOCAL_DNS_PORT 2>&-
            iptables -t nat -D PREROUTING -i $DNS_INT -p udp --dport 53 -j REDIRECT --to-ports $LOCAL_DNS_PORT 2>&-

            iptables -t nat -A PREROUTING -i $DNS_INT -p tcp --dport 53 -j REDIRECT --to-ports $LOCAL_DNS_PORT
            iptables -t nat -A PREROUTING -i $DNS_INT -p udp --dport 53 -j REDIRECT --to-ports $LOCAL_DNS_PORT
        ;;

        disable)
            stop_dns_redirect
            iptables -t nat -D PREROUTING -i $DNS_INT -p tcp --dport 53 -j REDIRECT --to-ports $LOCAL_DNS_PORT
            iptables -t nat -D PREROUTING -i $DNS_INT -p udp --dport 53 -j REDIRECT --to-ports $LOCAL_DNS_PORT
        ;;
        *)
            print_usage
    esac
fi

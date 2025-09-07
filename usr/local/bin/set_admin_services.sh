#!/bin/sh

[ $# -eq 0 ] && { echo -e "\nUsage:\n `basename $0` commercial / debug\n"; exit 1; }

ORIG_SERVICE_HTTP_STATUS=`uci get admin.services.http`
ORIG_SERVICE_FTP_STATUS=`uci get admin.services.ftp`
ORIG_SERVICE_TELNET_STATUS=`uci get admin.services.telnet`
ORIG_SERVICE_TFTP_STATUS=`uci get admin.services.tftp`
ORIG_SERVICE_SSH_STATUS=`uci get admin.services.ssh`

change_service_status()
{
    NEW_SERVICE_HTTP_STATUS=`uci get admin.services.http`
    NEW_SERVICE_FTP_STATUS=`uci get admin.services.ftp`
    NEW_SERVICE_TELNET_STATUS=`uci get admin.services.telnet`
    NEW_SERVICE_TFTP_STATUS=`uci get admin.services.tftp`
    NEW_SERVICE_SSH_STATUS=`uci get admin.services.ssh`

    if [ $NEW_SERVICE_HTTP_STATUS !=  $ORIG_SERVICE_HTTP_STATUS ]
    then
        if [ -f /etc/init.d/S93www ]
        then
            if [ $NEW_SERVICE_HTTP_STATUS !=  "enable" ]
            then
                /etc/init.d/S93www stop
            else
                /etc/init.d/S93www start
            fi
        fi
    fi

    if [ $NEW_SERVICE_FTP_STATUS !=  $ORIG_SERVICE_FTP_STATUS ]
    then
        if [ -f /etc/init.d/S98ftpd ]
        then
            if [ $NEW_SERVICE_FTP_STATUS !=  "enable" ]
            then
                /etc/init.d/S98ftpd stop
            else
                /etc/init.d/S98ftpd start
            fi
        fi
    fi

    if [ $NEW_SERVICE_TELNET_STATUS !=  $ORIG_SERVICE_TELNET_STATUS ]
    then
        if [ -f /etc/init.d/S97telnetd ]
        then
            if [ $NEW_SERVICE_SSH_STATUS !=  "enable" ]
            then
                /etc/init.d/S97telnetd stop
            else
                /etc/init.d/S97telnetd start
            fi
        fi
    fi

    if [ $NEW_SERVICE_SSH_STATUS !=  $ORIG_SERVICE_SSH_STATUS ]
    then
        if [ -f /etc/init.d/S95dropbear ]
        then
            if [ $NEW_SERVICE_SSH_STATUS !=  "enable" ]
            then
                /etc/init.d/S95dropbear stop
            else
                /etc/init.d/S95dropbear start
            fi
        fi
    fi
}


case "$1" in
    commercial)
        cp /etc/admin/admin_commercial /etc/config/admin
        ;;
    debug)
        cp /etc/admin/admin_debug /etc/config/admin
        ;;
        *)
        echo -e "\nUnknown arg $1\n\nUsage:\n `basename $0` commercial / debug\n"
        exit 1
        ;;
esac

change_service_status > /dev/null 2>&1 & 



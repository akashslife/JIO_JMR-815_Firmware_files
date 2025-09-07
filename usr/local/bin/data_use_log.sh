#!/bin/sh

# ALT3100_PWRT_03_00_04_00_14 : Change the "First PDN Device" : lte0 -> lte0.1
#WAN_INTERFACE="lte0"
WAN_INTERFACE="lte0.1"
REF_DATE="2013"

CUR_DATE=`date | awk '{ print $6 }'`

while [ $CUR_DATE -lt $REF_DATE ]; do
    sleep 5

    CUR_DATE=`date | awk '{ print $6 }'`
done

# if WEB_GUI_REQUEST_1_5 // After boot up, this information is initialized.
mkdir -p /tmp/db
mkdir -p /tmp/db_backup
# else
# mkdir -p /etc/config/db
# mkdir -p /etc/config/db_backup
# endif

while [ 1 ]; do
    #echo vnstat run!!!
    #Sometime, can't update : free disk not enough : add "--force" option
    vnstat -u -i $WAN_INTERFACE --force

#    sleep 10
    sleep 5
done


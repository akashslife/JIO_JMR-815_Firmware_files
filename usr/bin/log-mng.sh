#!/bin/sh


while [ 1 ]; do
logrotate /etc/logrotate.conf -s /tmp/logrotate.status > /dev/null 2>&1
sleep $1
done


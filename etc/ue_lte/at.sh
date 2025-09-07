#! /bin/sh

TIMEOUT_S=$2
if [ -z $TIMEOUT_S ]
then
        TIMEOUT_S=5
fi

echo "running $1"
(echo -e $1 & exec sleep $TIMEOUT_S) | socat /tmp/atsw15,nonblock,crnl stdio


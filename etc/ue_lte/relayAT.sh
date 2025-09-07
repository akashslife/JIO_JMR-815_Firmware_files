#!/bin/sh

echo "Relaying AT commands opened"

while [ 1 ]
do
   socat -d -d UNIX-CONNECT:/tmp/atsw0 TCP-LISTEN:5555,reuseaddr,nonblock
   sleep 1
done





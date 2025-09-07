#!/bin/sh

cd /sys/class/gpio/
echo 50 > export
cd gpio50
echo out > direction
echo 0 > value
cd ..
echo 50 > unexport 
echo "internal antenna is selected"



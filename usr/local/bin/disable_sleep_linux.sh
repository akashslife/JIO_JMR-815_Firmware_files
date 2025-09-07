#!/bin/sh
#disable sleep at linux level
echo 0 >  `find /sys -name sleep_enable`


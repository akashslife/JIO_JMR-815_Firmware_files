#! /bin/sh
echo "Drop Caches..." > /dev/kmsg
echo 3 > /proc/sys/vm/drop_caches
cat /proc/meminfo | head -n 5 > /dev/kmsg

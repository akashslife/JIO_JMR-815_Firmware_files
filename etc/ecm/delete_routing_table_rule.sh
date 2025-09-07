#!/bin/sh
TABLE=$1
echo $0: delete table $TABLE > dev/kmsg
ip rule delete table $TABLE 
ip -6 rule delete table $TABLE

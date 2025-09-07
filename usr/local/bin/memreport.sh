#!/bin/sh

export REPORT_DIR=/tmp/mem_report
export LOC_SMEMCAP=$REPORT_DIR/loc_smemcap

MEM_REPORT_TARFILE=mem_report_00.tar

LOC_SMEMCAP_TARFILE=loc_smemcap.tar
LOC_SMEMCAP_TARBALL_FILE=/tmp/$LOC_SMEMCAP_TARFILE.gz

echo "Mem report"

if [ -d  $REPORT_DIR ]; then
	echo "Cleaning mem report dir"
	rm -rf $REPORT_DIR
fi

mkdir $REPORT_DIR
mkdir $LOC_SMEMCAP

ps -ef > $REPORT_DIR/ps.txt

#cat /proc/meminfo > $REPORT_DIR/meminfo.txt
cat /proc/meminfo > $REPORT_DIR/meminfo_before.txt; sync; echo 3 > /proc/sys/vm/drop_caches; cat /proc/meminfo > $REPORT_DIR/meminfo_after.txt;
dmesg | grep Memory > $REPORT_DIR/kernel_mem_allocation.txt
df > $REPORT_DIR/df.txt

cat $REPORT_DIR/ps.txt | tail -n +2 |  awk ' { print $1 } '  | do_process_pid.sh

# complete creation of smemcap directory
cp /proc/meminfo $LOC_SMEMCAP
cp /proc/version $LOC_SMEMCAP

cd /tmp
if [ -e $MEM_REPORT_TARFILE ]; then
   rm -f  $MEM_REPORT_TARFILE
fi
if [ -e $LOC_SMEMCAP_TARBALL_FILE ]; then
   rm -f  $LOC_SMEMCAP_TARBALL_FILE 
fi
MEM_REPORT_TARBALL_FILE=$MEM_REPORT_TARFILE.gz
if [ -e $MEM_REPORT_TARBALL_FILE ]; then
   rm -f  $MEM_REPORT_TARBALL_FILE
fi
tar cvf $MEM_REPORT_TARFILE $REPORT_DIR/*
gzip $MEM_REPORT_TARFILE

# create a seperate smemcap like tarball (also included in the general mem_report.tar.gz)
cd $LOC_SMEMCAP
tar cvf /tmp/$LOC_SMEMCAP_TARFILE *
gzip /tmp/$LOC_SMEMCAP_TARFILE

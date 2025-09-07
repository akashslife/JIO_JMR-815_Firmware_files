##########################################################################################################################################
### The process save new statistics file
##########################################################################################################################################

echo Start Executing CollectStatistics.sh > /dev/kmesg

#device information (IMEI + VER). if the file device_info.txt doesn't exist - create it
device_info_path=/tmp/Collect_Statistics_Device_Info.txt

if [ ! -f $device_info_path ]; then
	imei=$(/etc/ue_lte/at.sh at+cgsn 0 | egrep -o '[0-9]*')
	echo IMEI: $imei > $device_info_path
	#VER
	ver_line=$(cat /nvm/etc/config/version | grep Ver)
	ver_isolated=$(echo $ver_line | cut -f 2 -d 'r' )
	echo NP Version:$ver_isolated >> $device_info_path	
fi

#Get current imei, date, time, and system uptime
imei=$(grep IMEI $device_info_path | egrep -o '[0-9]*')
underline="_"
date_and_time_str=$(date)
date_and_time_for_filename=$(date +"%Y_%m_%d_%H_%M")
sysuptime_str=$(uptime)

#remove all files in the statistics directory
statistics_directory_path=/nvm/Collect_Statistics_Statistics_Files/
if [ ! -d $statistics_directory_path ]; then
	mkdir $statistics_directory_path
fi
rm -rf $statistics_directory_path/*

#Creating the statistics file path
statistics_file_path=$statistics_directory_path/statistics_$imei$underline$date_and_time_for_filename.txt

#add device information to statistics file, date and time , uptime and event type
cat $device_info_path > $statistics_file_path
echo $date_and_time_str >> $statistics_file_path
echo $sysuptime_str >> $statistics_file_path
echo ----------------------------------->>$statistics_file_path 
#save add at%count counters to counters file
/etc/ue_lte/at.sh 'at%count="PDM"' 0 >>$statistics_file_path
echo ----------------------------------->>$statistics_file_path 
/etc/ue_lte/at.sh 'at%count="reselection"' 0 >>$statistics_file_path
echo ----------------------------------->>$statistics_file_path 
/etc/ue_lte/at.sh 'at%count="rrc"' 0 >>$statistics_file_path
echo ----------------------------------->>$statistics_file_path 
/etc/ue_lte/at.sh 'at%count="nas"' 0 >>$statistics_file_path
echo ----------------------------------->>$statistics_file_path 
/etc/ue_lte/at.sh 'at%count="usim"' 0 >>$statistics_file_path
echo ----------------------------------->>$statistics_file_path 
/etc/ue_lte/at.sh 'at%count="pwr"' 0 >>$statistics_file_path
echo ----------------------------------->>$statistics_file_path 
/etc/ue_lte/at.sh 'at%count="pwr_timers_history"' 0 >>$statistics_file_path
echo ----------------------------------->>$statistics_file_path 
/etc/ue_lte/at.sh 'at%count="pwr_phy"' 0 >>$statistics_file_path
echo ----------------------------------->>$statistics_file_path 
/etc/ue_lte/at.sh 'at%LSTASSRT?' 0 >>$statistics_file_path
echo ----------------------------------->>$statistics_file_path 
/etc/ue_lte/at.sh 'at%status="hbr_guards"' 0 >>$statistics_file_path
echo ----------------------------------->>$statistics_file_path 
/etc/ue_lte/at.sh 'at%status="rrc"' 0 >>$statistics_file_path
echo ----------------------------------->>$statistics_file_path 
/etc/ue_lte/at.sh 'at%status="PhySleep"' 0 >>$statistics_file_path                                                                                                        

#/etc/ue_lte/Events_Detector/System_Helper/upload_file_to_box.sh $statisticsFileName true
echo Done Executing CollectStatistics.sh > /dev/kmesg

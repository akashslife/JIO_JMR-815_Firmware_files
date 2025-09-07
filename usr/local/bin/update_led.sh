#!/bin/sh


SLEEP_TIME=1

LED_OFF(){
echo "0" >/sys/class/leds/Battery_RED/brightness
echo "0" >/sys/class/leds/Battery_GREEN/brightness
echo "0" >/sys/class/leds/Wifi_RED/brightness
echo "0" >/sys/class/leds/Wifi_GREEN/brightness
echo "0" >/sys/class/leds/Lte_RED/brightness
echo "0" >/sys/class/leds/Lte_GREEN/brightness    
echo "0" >/sys/class/leds/Lte_BLUE/brightness
sleep $SLEEP_TIME
}

B_GREEN(){
echo "0" >/sys/class/leds/Battery_BLUE/brightness
echo "0" >/sys/class/leds/Battery_RED/brightness
echo "255" >/sys/class/leds/Battery_GREEN/brightness
sleep $SLEEP_TIME
}

W_GREEN(){
echo "0" >/sys/class/leds/Wifi_RED/brightness
echo "255" >/sys/class/leds/Wifi_GREEN/brightness
echo "0" >/sys/class/leds/Wifi_BLUE/brightness
sleep $SLEEP_TIME
}

L_GREEN(){
echo "0" >/sys/class/leds/Lte_RED/brightness
echo "255" >/sys/class/leds/Lte_GREEN/brightness
echo "0" >/sys/class/leds/Lte_BLUE/brightness
sleep $SLEEP_TIME
}

B_RED(){
echo "255" >/sys/class/leds/Battery_RED/brightness
echo "0" >/sys/class/leds/Battery_GREEN/brightness
echo "0" >/sys/class/leds/Battery_BLUE/brightness
sleep $SLEEP_TIME
}

W_RED(){
echo "255" >/sys/class/leds/Wifi_RED/brightness
echo "0" >/sys/class/leds/Wifi_GREEN/brightness
echo "0" >/sys/class/leds/Wifi_BLUE/brightness
sleep $SLEEP_TIME
}

L_RED(){
echo "255" >/sys/class/leds/Lte_RED/brightness
echo "0" >/sys/class/leds/Lte_GREEN/brightness
echo "0" >/sys/class/leds/Lte_BLUE/brightness
sleep $SLEEP_TIME
}

B_ORANGE(){
echo "255" >/sys/class/leds/Battery_GREEN/brightness
echo "255" >/sys/class/leds/Battery_RED/brightness
sleep $SLEEP_TIME
}

#jwpark
B_BLUE(){
echo "255" >/sys/class/leds/Battery_BLUE/brightness
echo "0" >/sys/class/leds/Battery_GREEN/brightness
echo "0" >/sys/class/leds/Battery_RED/brightness
sleep $SLEEP_TIME
}

W_ORANGE(){
echo "255" >/sys/class/leds/Wifi_GREEN/brightness
echo "255" >/sys/class/leds/Wifi_RED/brightness
sleep $SLEEP_TIME
}

W_BLUE(){
echo "0" >/sys/class/leds/Wifi_GREEN/brightness
echo "0" >/sys/class/leds/Wifi_RED/brightness
echo "255" >/sys/class/leds/Wifi_BLUE/brightness
sleep $SLEEP_TIME
}

L_ORANGE(){
echo "255" >/sys/class/leds/Lte_GREEN/brightness
echo "255" >/sys/class/leds/Lte_RED/brightness
echo "0" >/sys/class/leds/Lte_BLUE/brightness
sleep $SLEEP_TIME
}

L_BLUE(){
echo "0" >/sys/class/leds/Lte_GREEN/brightness
echo "0" >/sys/class/leds/Lte_RED/brightness
echo "255" >/sys/class/leds/Lte_BLUE/brightness
sleep $SLEEP_TIME
}

L_VIR(){
echo "0" >/sys/class/leds/Lte_GREEN/brightness
echo "255" >/sys/class/leds/Lte_RED/brightness
echo "255" >/sys/class/leds/Lte_BLUE/brightness
sleep $SLEEP_TIME
}

L_LB(){
echo "255" >/sys/class/leds/Lte_GREEN/brightness
echo "0" >/sys/class/leds/Lte_RED/brightness
echo "255" >/sys/class/leds/Lte_BLUE/brightness  
sleep $SLEEP_TIME
}

L_WHITE(){
echo "255" >/sys/class/leds/Lte_GREEN/brightness
echo "255" >/sys/class/leds/Lte_RED/brightness
echo "255" >/sys/class/leds/Lte_BLUE/brightness
sleep $SLEEP_TIME 
}


#turn off leds, kill & block pwrt_sm
touch -f /tmp/led_test
killall pwrt_sm
LED_OFF

while [ 1 ];do
L_LED="L_GREEN L_RED L_BLUE"
B_LED="B_GREEN B_RED B_BLUE"
W_LED="W_GREEN W_RED W_BLUE" 
UPDATE="B_GREEN L_GREEN W_GREEN W_BLUE W_RED L_RED B_RED B_BLUE"

for i in $UPDATE
do
	$i
done
done

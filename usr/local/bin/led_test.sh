#!/bin/sh

touch /tmp/led_test
killall pwrt_sm_check.sh
killall pwrt_sm

echo "none" >/sys/class/leds/Wifi_RED/trigger
echo "none" >/sys/class/leds/Wifi_GREEN/trigger
echo "none" >/sys/class/leds/Wifi_BLUE/trigger
echo "none" >/sys/class/leds/Lte_RED/trigger
echo "none" >/sys/class/leds/Lte_GREEN/trigger
echo "none" >/sys/class/leds/Lte_BLUE/trigger
echo "none" > /sys/class/leds/Battery_RED/trigger
echo "none" > /sys/class/leds/Battery_GREEN/trigger
echo "none" > /sys/class/leds/Battery_BLUE/trigger
echo "0" >/sys/class/leds/Wifi_BLUE/brightness
echo "0" >/sys/class/leds/Wifi_RED/brightness
echo "0" >/sys/class/leds/Wifi_GREEN/brightness
echo "0" >/sys/class/leds/Lte_RED/brightness
echo "0" >/sys/class/leds/Lte_GREEN/brightness
echo "0" >/sys/class/leds/Lte_BLUE/brightness
echo "0" > /sys/class/leds/Battery_GREEN/brightness
echo "0" > /sys/class/leds/Battery_GREEN/brightness
echo "0" > /sys/class/leds/Battery_GREEN/brightness

LED_NAME=$1 
LED_NUM=$2 
LED_ON=$3


if [ $LED_NAME = "ALL" ]; then
  if [ $LED_ON = "ON" ]; then
    if [ $LED_NUM = "GREEN" ]; then
      echo "1" >/sys/class/leds/Wifi_GREEN/brightness
      echo "1" >/sys/class/leds/Lte_GREEN/brightness
      echo "1" > /sys/class/leds/Battery_GREEN/brightness
    fi
  elif [ $LED_ON = "OFF" ]; then
	    if [ $LED_NUM = "ALL" ]; then
	      echo "none" >/sys/class/leds/Wifi_RED/trigger
	      echo "none" >/sys/class/leds/Wifi_GREEN/trigger
	      echo "none" >/sys/class/leds/Wifi_BLUE/trigger
	      echo "none" >/sys/class/leds/Lte_RED/trigger
	      echo "none" >/sys/class/leds/Lte_GREEN/trigger
	      echo "none" >/sys/class/leds/Lte_BLUE/trigger
	      echo "none" > /sys/class/leds/Battery_RED/trigger
	      echo "none" > /sys/class/leds/Battery_GREEN/trigger
	      echo "none" > /sys/class/leds/Battery_BLUE/trigger
	      echo "0" >/sys/class/leds/Wifi_BLUE/brightness
	      echo "0" >/sys/class/leds/Wifi_RED/brightness
	      echo "0" >/sys/class/leds/Wifi_GREEN/brightness
	      echo "0" >/sys/class/leds/Lte_RED/brightness
	      echo "0" >/sys/class/leds/Lte_GREEN/brightness
	      echo "0" >/sys/class/leds/Lte_BLUE/brightness
	      echo "0" > /sys/class/leds/Battery_RED/brightness
	      echo "0" > /sys/class/leds/Battery_GREEN/brightness
	      echo "0" > /sys/class/leds/Battery_BLUE/brightness
	      echo "OK"	  	
	    fi
  fi
fi
if [ $LED_NAME = "LTE" ]; then
  if [ $LED_ON = "ON" ]; then
    if [ $LED_NUM = "GREEN" ]; then
      echo 1 > /sys/class/leds/Lte_GREEN/brightness
      echo "OK"
    elif [ $LED_NUM = "RED" ]; then
      echo 1 > /sys/class/leds/Lte_RED/brightness
      echo "OK"
    elif [ $LED_NUM = "BLUE" ]; then
      echo 1 > /sys/class/leds/Lte_BLUE/brightness
      echo "OK"
    else
      echo "NG"
    fi
  elif [ $LED_ON = "OFF" ]; then
    if [ $LED_NUM = "GREEN" ]; then
      echo 0 > /sys/class/leds/Lte_GREEN/brightness
      echo "OK"
    elif [ $LED_NUM = "RED" ]; then
      echo 0 > /sys/class/leds/Lte_RED/brightness
      echo "OK"
    elif [ $LED_NUM = "BLUE" ]; then
      echo 0 > /sys/class/leds/Lte_BLUE/brightness
      echo "OK"
    else
      echo "NG"
    fi
  else
  echo "NG"
  fi
  echo "OK"
fi

if [ $LED_NAME = "BATTERY" ]; then
  if [ $LED_ON = "ON" ]; then
    if [ $LED_NUM = "GREEN" ]; then
      echo 1 > /sys/class/leds/Battery_GREEN/brightness
    elif [ $LED_NUM = "RED" ]; then
      echo 1 > /sys/class/leds/Battery_RED/brightness
    elif [ $LED_NUM = "BLUE" ]; then
      echo 1 > /sys/class/leds/Battery_BLUE/brightness
    fi
  elif [ $LED_ON = "OFF" ]; then
    if [ $LED_NUM = "GREEN" ]; then
      echo 0 > /sys/class/leds/Battery_GREEN/brightness
    elif [ $LED_NUM = "RED" ]; then
      echo 0 > /sys/class/leds/Battery_RED/brightness
    elif [ $LED_NUM = "BLUE" ]; then
      echo 0 > /sys/class/leds/Battery_BLUE/brightness
    fi
  fi
  echo "OK"
fi

if [ $LED_NAME = "WIFI" ]; then
  if [ $LED_ON = "ON" ]; then
    if [ $LED_NUM = "GREEN" ]; then
      echo 1 > /sys/class/leds/Wifi_GREEN/brightness
    elif [ $LED_NUM = "RED" ]; then
      echo 1 > /sys/class/leds/Wifi_RED/brightness
    elif [ $LED_NUM = "BLUE" ]; then
      echo 1 > /sys/class/leds/Wifi_BLUE/brightness
    fi
  elif [ $LED_ON = "OFF" ]; then
    if [ $LED_NUM = "GREEN" ]; then
      echo 0 > /sys/class/leds/Wifi_GREEN/brightness
    elif [ $LED_NUM = "RED" ]; then
      echo 0 > /sys/class/leds/Wifi_RED/brightness
    elif [ $LED_NUM = "BLUE" ]; then
      echo 0 > /sys/class/leds/Wifi_BLUE/brightness
    fi
  fi
  echo "OK"
fi

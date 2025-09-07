#!/bin/sh
#
#  Initialize Fuel Gauge BQ27426G1.
#
#

# Battery Capacity
let BATTERY_CAPACITY=3000
# Battery Energy 3000mA * 3.8V
let BATTERY_ENERGY=11400
# Terminate Voltage
let TERMINATE_VOLTAGE=3050
# Voltage at Charge Termination
let VatChgTerm=4300

#Export the relevent interfaces name
. /usr/local/bin/lte-gw-global-env.sh

FG_CHIPID=85
CHRG_CHIPID=107
FG_I2C_BUS=0
CHRG_I2C_BUS=0

open_flash_access()
{
 let SUBCLASS=$1

 i2cset -y $FG_I2C_BUS $FG_CHIPID 0x61 0         # BlockDataControl - enable flash data access 
 i2cset -y $FG_I2C_BUS $FG_CHIPID 0x3e $SUBCLASS # DataFlashClass - access registers subclass
 i2cset -y $FG_I2C_BUS $FG_CHIPID 0x3f 0         # 32 bytes block offset 
}

update_checksum()
{
 let SUM=0
 let i=0

 # calc block sum
 while [ $i -lt 32 ]; do
  let SUM+=$(i2cget -y $FG_I2C_BUS $FG_CHIPID $((0x40 + $i)))
  let i+=1
 done

 LSB=$(($SUM & 0xff))

 let CHECK_SUM=255-$LSB

 i2cset -y $FG_I2C_BUS $FG_CHIPID 0x60 $CHECK_SUM

 usleep 100000 # at least 50ms
}

update_battery_capacity()
{
 let CLASS=$1
 let REG_ADDR=$2
 let CAPACITY=$3

 # change bytes order
 let NEW_REG_VAL=$(( (($CAPACITY & 0xff) << 8) + (($CAPACITY & 0xff00) >> 8) ))

 open_flash_access $CLASS

 let REG_VAL=$(i2cget -y $FG_I2C_BUS $FG_CHIPID $REG_ADDR w)

 # already done
 if [ $REG_VAL -eq $NEW_REG_VAL ]; then
  return
 fi

 printf "Fuel Gauge battery capacity init (class=$CLASS, reg_addr=$REG_ADDR)\n"  

 i2cset -y $FG_I2C_BUS $FG_CHIPID $REG_ADDR $NEW_REG_VAL w

 update_checksum

 let REG_VAL=$(i2cget -y $FG_I2C_BUS $FG_CHIPID $REG_ADDR w)

 if [ $REG_VAL -ne $NEW_REG_VAL ]; then
  echo "Battery capacity init error! (class=$CLASS, reg_addr=$REG_ADDR)\n"
 fi
}

update_ra_table()
{
 let CLASS=$1
 let REG_ADDR=$2
 let RA_VALUE=$3
 
 # change bytes order
 let NEW_REG_VAL=$(( (($RA_VALUE & 0xff) << 8) + (($RA_VALUE & 0xff00) >> 8) ))
 
 open_flash_access $CLASS

 let REG_VAL=$(i2cget -y $FG_I2C_BUS $FG_CHIPID $REG_ADDR w)

 # already done
 if [ $REG_VAL -eq $NEW_REG_VAL ]; then
  return
 fi

 printf "Fuel Gauge ra table init (class=$CLASS, reg_addr=$REG_ADDR)\n"

 i2cset -y $FG_I2C_BUS $FG_CHIPID $REG_ADDR $NEW_REG_VAL w

 update_checksum
 
 let REG_VAL=$(i2cget -y $FG_I2C_BUS $FG_CHIPID $REG_ADDR w)

 if [ $REG_VAL -ne $NEW_REG_VAL ]; then
  echo "Battery capacity init error! (class=$CLASS, reg_addr=$REG_ADDR)\n"  
 fi
}

production_temperature_sensor()
{
 # Use internal sensor rather than TS pin - op config register, TEMPS bit=0
 
 let REG_ADDR=65
 
 open_flash_access 64

 REG_VAL=$(i2cget -y $FG_I2C_BUS $FG_CHIPID $REG_ADDR)

 REG_VAL=$(($REG_VAL | 0x01))

 echo "Fuel Gauge temperature sensor init ( reg_val=$REG_VAL)" 

 NEW_REG_VAL=$(($REG_VAL & 0xff))

 i2cset -y $FG_I2C_BUS $FG_CHIPID $REG_ADDR $NEW_REG_VAL

 update_checksum

 let REG_VAL=$(i2cget -y $FG_I2C_BUS $FG_CHIPID $REG_ADDR)

 if [ $REG_VAL -ne $NEW_REG_VAL ]; then
  echo "Temperature Sensor init error!"
 fi
}

production_battery_capacity()
{
# Set Design Capacity
 update_battery_capacity 82 70 $BATTERY_CAPACITY
# Set Design Energy 
 update_battery_capacity 82 72 $BATTERY_ENERGY
# Set Terminate Voltage
 update_battery_capacity 82 74 $TERMINATE_VOLTAGE
# Set Voltage at Charge Termination
 update_battery_capacity 109 70 $VatChgTerm
}

production_ra_table()
{
 open_flash_access 89

 update_ra_table 89 64 156
 update_ra_table 89 66 70
 update_ra_table 89 68 78
 update_ra_table 89 70 90
 update_ra_table 89 72 84
 update_ra_table 89 74 72
 update_ra_table 89 76 78
 update_ra_table 89 78 72
 update_ra_table 89 80 70
 update_ra_table 89 82 74
 update_ra_table 89 84 76
 update_ra_table 89 86 80
 update_ra_table 89 88 92
 update_ra_table 89 90 108
 update_ra_table 89 92 95
}

### START ###

# check communication with charger
i2cget -y $CHRG_I2C_BUS $CHRG_CHIPID 1 > /dev/null 2>&1
if [ $? -ne 0 ]; then
# echo "Platform do not support battery"
  exit
fi

# check communication with fuel gauge
i2cget -y $FG_I2C_BUS $FG_CHIPID 0x06 > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Fuel Gauge reading error - battery does not exist!"
  echo "Fuel Gauge reading error - battery does not exist!" > /dev/kmsg
  exit
fi

CONTROL_STATUS=$(i2cget -y $FG_I2C_BUS $FG_CHIPID 0 w)
SEALED_STATE=$((($CONTROL_STATUS & 0x2000)>>13))


echo "Change to UNSEALED MODE in Fuel Gauge"
i2cset -y $FG_I2C_BUS $FG_CHIPID 0 0x8000 w 
i2cset -y $FG_I2C_BUS $FG_CHIPID 0 0x8000 w

# Send SET_CFGUPDATE subcommand, Control(0x0013).
i2cset -y $FG_I2C_BUS $FG_CHIPID 0 0x0013 w

# Confirm CFGUPDATE mode by polling Flags() register until bit 4 is set. May take up to 1 second.
let CFGUPDATE_STATE=0
let i=0

while [ $CFGUPDATE_STATE -eq 0 ];do
  if [ $i -eq 100 ]; then
    echo "Fuel Gauge cfgupdate set error"
    echo "Fuel Gauge cfgupdate set error" > /dev/kmsg  
    exit
  fi
  let i+=1
  FLAGS_STATUS=$(i2cget -y $FG_I2C_BUS $FG_CHIPID 0x06 w)
  CFGUPDATE_STATE=$((($FLAGS_STATUS & 0x0010)>>4))
  usleep 200000
  echo "Waiting to Begin CFGUPDATE mode"
done 

echo "Begin CFGUPDATE mode"
production_temperature_sensor
production_battery_capacity
production_ra_table
# Exit CFGUPDATE mode by sending SOFT_RESET subcommand, Control(0x0042).
i2cset -y $FG_I2C_BUS $FG_CHIPID 0 0x0042 w 
  
#Confirm CFGUPDATE has been exited by polling Flags() register until bit 4 is cleared. May take up to 1 second.
let CFGUPDATE_STATE=1
let i=0

while [ $CFGUPDATE_STATE -eq 1 ];do
  if [ $i -eq 100 ]; then
    echo "Fuel Gauge cfgupdate clear error"
    echo "Fuel Gauge cfgupdate clear error" > /dev/kmsg  
    exit
  fi
  let i+=1
  FLAGS_STATUS=$(i2cget -y $FG_I2C_BUS $FG_CHIPID 0x06 w)
  CFGUPDATE_STATE=$((($FLAGS_STATUS & 0x0010)>>4))
  usleep 200000
  echo "Waiting to Exit CFGUPDATE mode"
done 
  
# set sealed state
i2cset -y $FG_I2C_BUS $FG_CHIPID 0 0x20 w 

FLAGS=$(i2cget -y $FG_I2C_BUS $FG_CHIPID 0x6 w)
BAT_DETECTION=$((($FLAGS & 0x8)>>3))

if [ $BAT_DETECTION -ne 1 ]; then
 echo "Battery detection error!"              
 echo "Battery detection error!" > /dev/kmsg 
fi

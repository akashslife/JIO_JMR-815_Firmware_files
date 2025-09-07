#!/bin/sh

test_done()
{
        echo "TEST DONE"
        read DONE
}

flash_all_leds1()
{
    LEDS_PATH=/sys/class/leds/

    for i in `ls $LEDS_PATH`; do
        cd $LEDS_PATH/$i;
        echo "none" > trigger;
        echo 0 > brightness;
    done
    for i in `ls $LEDS_PATH`; do
        echo $i ; echo "---------";
        cd $LEDS_PATH/$i;
        echo "none" > trigger;
        echo 1 > brightness;
        usleep 500000;
        echo 0 > brightness;
        usleep 500000;
        echo 1 > brightness;
        usleep 500000;
        echo 0 > brightness;

    done
    test_done
}

flash_all_leds_by_gpio()
{

    BIT0=$((1<<0))
    BIT1=$((1<<1))
    BIT2=$((1<<2))
    BIT3=$((1<<3))
    BIT4=$((1<<4))
    BIT5=$((1<<5))
    BIT6=$((1<<6))
    BIT7=$((1<<7))
    GP3=0xb4969bfc
    GP4=0xb496a3fc
    GP9=0xb496cbfc
    exit_loop=0
    #1 - off 
    #0 - on
    while [ $exit_loop -eq 0 ]; do
    
        echo "1. NTLR-210"
        echo "2. NTLR-310"
        echo "3. MyFi4.2"
        echo "0. return"
        read TYPE
        case $TYPE in 
            0)  exit_loop=1;;
            1)  REG=`devmem $GP4`;
                devmem $GP4 32 $(($REG | BIT4));
                REG=`devmem $GP9`;
                devmem $GP9 32 $(($REG | BIT5));
                REG=`devmem $GP9`;
                devmem $GP9 32 $(($REG | BIT6));
                echo "WIFI_BLUE";
                REG=`devmem $GP4`;
                devmem $GP4 32 $(($REG & ~BIT4));
                usleep 500000;
                devmem $GP4 32 $(($REG | BIT4));
                exit_loop=1;;
            2)  REG=`devmem $GP3`;
                devmem $GP3 32 $(($REG | BIT2));
                REG=`devmem $GP9`;
                devmem $GP9 32 $(($REG | BIT5));
                REG=`devmem $GP9`;
                devmem $GP9 32 $(($REG | BIT6));
                echo "WIFI_BLUE";
                REG=`devmem $GP3`;
                devmem $GP3 32 $(($REG & ~BIT2));
                usleep 500000;
                devmem $GP3 32 $(($REG | BIT2));
                exit_loop=1;;
            3)  REG=`devmem $GP3`;
                devmem $GP3 32 $(($REG | BIT3));
                REG=`devmem $GP9`;
                devmem $GP9 32 $(($REG | BIT5));
                REG=`devmem $GP9`;
                devmem $GP9 32 $(($REG | BIT6));
                echo "WIFI_BLUE";
                REG=`devmem $GP3`;
                devmem $GP3 32 $(($REG & ~BIT3));
                usleep 500000;
                devmem $GP3 32 $(($REG | BIT3));
                exit_loop=1;;

            *)  echo "wrong choise ["$TYPE"]";;
        esac
    done
    echo "WIFI_GREEN";
    REG=`devmem $GP9`;
    devmem $GP9 32 $(($REG & ~BIT5));
    usleep 500000;
    devmem $GP9 32 $(($REG | BIT5));
    echo "WIFI_RED";
    REG=`devmem $GP9`;
    devmem $GP9 32 $(($REG & ~BIT6));
    usleep 500000;
    devmem $GP9 32 $(($REG | BIT6));
    #----- LTE ----
    REG=`devmem $GP3`;
    devmem $GP3 32 $(($REG | BIT7));
    REG=`devmem $GP4`;
    devmem $GP4 32 $(($REG | BIT0));
    REG=`devmem $GP4`;
    devmem $GP4 32 $(($REG | BIT1));
    echo "LTE_1"
    REG=`devmem $GP3`;
    devmem $GP3 32 $(($REG & ~BIT7));
    usleep 500000;
    devmem $GP3 32 $(($REG | BIT7));
    echo "LTE_2"
    REG=`devmem $GP4`;
    devmem $GP4 32 $(($REG & ~BIT0));
    usleep 500000;
    devmem $GP4 32 $(($REG | BIT0));
    echo "LTE_3"
    REG=`devmem $GP4`;
    devmem $GP4 32 $(($REG & ~BIT1));
    usleep 500000;
    devmem $GP4 32 $(($REG | BIT1));
    #----- BATTERY -----
    REG=`devmem $GP3`;
    devmem $GP3 32 $(($REG | BIT4));
    REG=`devmem $GP3`;
    devmem $GP3 32 $(($REG | BIT5));
    REG=`devmem $GP3`;
    devmem $GP3 32 $(($REG | BIT6));
    echo "BATT_GREEN"
    REG=`devmem $GP3`;
    devmem $GP3 32 $(($REG & ~BIT4));
    usleep 500000;
    devmem $GP3 32 $(($REG | BIT4));
    echo "BATT_RED"
    REG=`devmem $GP3`;
    devmem $GP3 32 $(($REG & ~BIT5));
    usleep 500000;
    devmem $GP3 32 $(($REG | BIT5));
    echo "BATT_BLUE"
    REG=`devmem $GP3`;
    devmem $GP3 32 $(($REG & ~BIT6));
    usleep 500000;
    devmem $GP3 32 $(($REG | BIT6));

    test_done
}

flash_all_leds()
{
    echo "1. use /sys/class/gpio (only if you have proper dtb)"
    echo "2. use gpios"
    read SEL
    if [ $SEL -ne 1 ]; then
        echo "will use gpio"
        SEL=2
    fi
    case $SEL in 
        1) flash_all_leds1;;
        2) flash_all_leds_by_gpio;;
    esac

}
run_i2cdetect()
{
    i2cdetect -y 0;
    test_done
}
read_fg_registers ()
{
    echo "general stuff regarding battery"
    echo "-------------------------------"
    echo "press 1 for fuel gauge: BQ27520 (MYFI4.2)"
    echo "press 2 for fuel gauge: BQ27426 (NTLR310)"
    read TYPE
    if [ $TYPE -ne 1 ]; then
       TYPE=2
    fi
    if [ $TYPE -eq 1 ]; then
        echo 0" control     " `i2cget -y 0 0x55 0 w`;
        echo 6" temperature " `i2cget -y 0 0x55 6 w` " 0.1K";
        echo 8" voltage     " `i2cget -y 0 0x55 8 w` " mV";
    else
        echo 0" control     " `i2cget -y 0 0x55 0 w`;
        echo 6" temperature " `i2cget -y 0 0x55 2 w` " 0.1K";
        echo 8" voltage     " `i2cget -y 0 0x55 4 w` " mV";
    fi
}
read_chrg_registers()
{
    let i=0;
    while [ $i -lt 10 ]; do
        echo $i ":"`i2cget -y 0 0x6b $i`;
        let i=i+1;
    done
}
read_pmic_registers()
{
    let i=0;
    echo "DCDC registers"
    while [ $i -lt 16 ]; do
        echo $i ":"`i2cget -y 0 0x2d $i`;
        let i=i+1;
    done
}
run_i2c_read()
{
    exit_loop=0
    while [ $exit_loop -eq 0 ];
    do
        echo "------------------"
        echo "i2c read "
        echo "------------------"
        echo "1. Fuel Gauge"
        echo "2. Charger"
        echo "3. PMIC"
        echo "0. back to main"
        echo "select _"
        read I2CSEL
        case $I2CSEL in
            1) read_fg_registers;;
            2) read_chrg_registers;;
            3) read_pmic_registers;;
            0) exit_loop=1;;
            *) echo "bad choice [$I2CSEL]";;
        esac
    done
    test_done
}
run_flash_ad17_read ()
{
#gpio[4] out 2
#4*8+2+1 => 35
    if [ ! -e /sys/class/gpio/gpio35 ]; then
        echo "gpio35 was not exported - export it now";
        echo 35 > /sys/class/gpio/export;
    fi

    if [ ! -e /sys/class/gpio/gpio35 ]; then
        echo "gpio35 was not exported - test FAIL";
    else
        echo "current state of gpio 35: Direction " `cat /sys/class/gpio/gpio35/
direction` " value: "`cat /sys/class/gpio/gpio35/value`
    fi
    test_done
}

run_button ()
{
    echo "------------------"
    echo "button "
    echo "------------------"
    pmic_press=0
    wps_press=0
    res_def_press=0
    #PMIC_INT - power_on_off
    i2cset -y 0 0x2d 0x39 0xff
    i2cset -y 0 0x2d 0x3a 0x00
    echo "power on_off: current status:" `i2cget -y 0 0x2d 0x39`
    echo "please press button"
    start_time=`date +%s`
    while [ $((`date +%s`-start_time)) -lt 10 ]; do
        regval=`i2cget -y 0 0x2d 0x39`;
        if [ $((regval & 0x4)) -ne 0 ] ; then
            echo "power button pressed";
            pmic_press=1
            break;
        fi
    done
    if [ $pmic_press -ne 1 ]; then
       echo "pmic button was not pressed for 10 sec"
    fi
    echo "------------------"

    #WPS - NTLR210 GPIO5 - gpio0_out0 --> 1- NTLR-310 - SPI_MOSI - gpio5_out4 --> 5*8+4+1 = 45
    echo "press 1 for ntlr210"
    echo "press 2 for ntlr310"
    read TYPE
    if [ $TYPE -eq 1 ]; then
            WPS_GPIO="gpio1"
    else
            WPS_GPIO="gpio45"
    fi

    echo "WPS current status ("$WPS_GPIO") (1-ntlr210,45-ntlr310):" `cat /sys/class/gpio/$WPS_GPIO/value`
    echo "please press button"
    start_time=`date +%s`
    while [ $((`date +%s`-start_time)) -lt 10 ]; do
        regval=`cat /sys/class/gpio/$WPS_GPIO/value`;
        if [ $regval -ne 1 ] ; then
            echo "wps button pressed";
            wps_press=1
            break;
        fi
    done
    if [ $wps_press -ne 1 ]; then
       echo "wps button was not pressed for 10 sec"
    fi
    echo "------------------"

    #RES_DEF - NTLR210 ,NTLR-310 - gpio7 - gpio10_out4 --> 10*8+4+1 = 85
    RES_DEF_GPIO="gpio85"
    echo "RES_DEF current status ("$RES_DEF_GPIO") (1-ntlr210,45-ntlr310):" `cat /sys/class/gpio/$RES_DEF_GPIO/value`
    echo "please press button"
    start_time=`date +%s`
    while [ $((`date +%s`-start_time)) -lt 10 ]; do
        regval=`cat /sys/class/gpio/$RES_DEF_GPIO/value`;
        if [ $regval -ne 1 ] ; then
            echo "RES_DEF button pressed";
            res_def_press=1
            break;
        fi
    done
    if [ $res_def_press -ne 1 ]; then
       echo "RES_DEF button was not pressed for 10 sec"
    fi

    test_done
}

run_hw_ver ()
{
    echo "press 1 for NTLR-210 / MyFi4.2"
    echo "press 2 for NTLR-310"
    read TYPE
    if [ $TYPE -ne 1 ]; then
        TYPE=2;
    fi
    #           VER1    VER2
    # NTLR-210  AD8     AD9
    # MyFi 4.2  AD8     AD9
    # NTLR-310  AD8     AD10
    #flash_ad8 - gpio3_out1 --> 3*8+1+1 = 26
    #flash_ad9 - gpio3_out2 --> 3*8+2+1 = 27
    #flash_ad10- gpio3_out3 --> 3*8+3+1 = 28
    if [ $TYPE -eq 1 ]; then
        echo "HW_VER_02: FLASH_AD9: direction "`cat /sys/class/gpio/gpio27/direction`" value: " `cat /sys/class/gpio/gpio27/value`
        echo "HW_VER_01: FLASH_AD8: direction "`cat /sys/class/gpio/gpio26/direction`" value: " `cat /sys/class/gpio/gpio26/value`
    else
        echo "HW_VER_02: FLASH_AD10: direction "`cat /sys/class/gpio/gpio28/direction`" value: " `cat /sys/class/gpio/gpio28/value`
        echo "HW_VER_01: FLASH_AD8:  direction "`cat /sys/class/gpio/gpio26/direction`" value: " `cat /sys/class/gpio/gpio26/value`
    fi
    test_done
}

run_charger_gauge_general ()
{

    echo "general stuff regarding battery"
    echo "-------------------------------"
    echo "press 1 for fuel gauge: BQ27520 (MYFI4.2)"
    echo "press 2 for fuel gauge: BQ27426 (NTLR310)"
    read TYPE
    if [ $TYPE -ne 1 ]; then
       TYPE=2
    fi

    REGVAL=`i2cget -y 0 0x6b 0x1`
    if [ $(($REGVAL & 0x10)) -eq 16 ]; then
        echo "Charge Enable"
    else
        echo "Charge Disable"
    fi
    REGVAL=`i2cget -y 0 0x6b 0x8`
    VBUS_STAT=$((REGVAL & 0xc0))
    case  $(($VBUS_STAT >> 6)) in
        0) echo "0: unknown host";;
        1) echo "1: usb host";;
        2) echo "2: adapter host";;
        3) echo "3: otg";;
        *) echo "error reading host:" $(($VBUS_STAT >>6))
    esac
    CHRG_STAT=$((REGVAL & 0x30))
    case  $(($CHRG_STAT >> 4)) in
        0) echo "0: not charging";;
        1) echo "1: pre charge";;
        2) echo "2: fast charge";;
        3) echo "3: charge done";;
        *) echo "error reading chrg stat:" $(($CHRG_STAT >>4));;
    esac;
    echo "charger flt reg (0x09) val:"`i2cget -y 0 0x6b 0x9`
    if [ $TYPE -eq 1 ]; then #BQ27520
        printf "Voltage          %d mV\n" `i2cget -y 0 0x55 0x8  w`
        printf "StateOfCharge    %d %%\n" `i2cget -y 0 0x55 0x20 w`
        TMPR=`i2cget -y 0 0x55 0x6  w`
        printf "Temperature      %d C\n" $((TMPR/10 -273))
        TMPR=`i2cget -y 0 0x55 0x28  w`
        printf "Internal Tmpr    %d C\n" $((TMPR/10 -273))
    fi
    if [ $TYPE -eq 2 ]; then #BQ27426
        printf "Voltage          %d mV\n" `i2cget -y 0 0x55 0x4  w`
        printf "StateOfCharge    %d %%\n" `i2cget -y 0 0x55 0x1c w`
        TMPR=`i2cget -y 0 0x55 0x2  w`
        printf "Temperature      %d C\n" $((TMPR/10 -273))
        TMPR=`i2cget -y 0 0x55 0x1e  w`
        printf "internal Tmpr    %d C\n" $((TMPR/10 -273))
    fi

    test_done
}

run_sleep_counters ()
{
    /etc/ue_lte/at.sh 'at%count="pwr"' 1
    echo "-------------------------------------------"
    cat /sys/devices/soc.0/b0220200.pm/sleep_status
    echo "-------------------------------------------"
    cat /sys/devices/soc.0/b0220200.pm/sleep_counters
    test_done
}
run_some_at_commands ()
{
    exit_loop=0;
    while [ $exit_loop -eq 0 ];
    do
        echo "1. AT%VER"
        echo "2. AT+CFUN=0"
        echo "3. AT+CFUN=1"
        echo "0. return"
        read CMD
        case $CMD in
            1) /etc/ue_lte/at.sh at%ver 1;;
            2) /etc/ue_lte/at.sh at+cfun=0;;
            3) /etc/ue_lte/at.sh at+cfun=1;;
            0) exit_loop=1;;
            *) echo "wrong selection ["$CMD"]"
        esac
    done
}

run_sd_card ()
{
    echo "--------------------- mount ----------------------"
    mount
    echo "----------------  mmc blk devices -----------------"
    ls /dev/mmcb*
    echo "-------------------------------------------"
    if [ `mount | grep mmcblk | wc -l` -eq 1 ]; then
        MNT_PNT=`mount | grep mmcblk | awk '{ print $3 }'`
        echo "SD Card already mounted on "$MNT_PNT" :"  
        ls $MNT_PNT
    else
        if [ `ls /dev/mmcblk* | wc -l` -eq 0 ]; then
            echo "SD Card not found"
        else
            echo "SD Card found - but not mounted"
            echo " please try to use \"mount -t msdos /dev/mmcblk0p1  /mnt/\""  
        fi
    fi
    test_done
}
#------------------ MAIN ------------------
killall pwrt_sm
while [ 1 ];
do
    clear
    echo "==========================================="
    echo " HW Tests "
    echo "==========================================="
    echo "1. flash all leds (sys/class/leds)"
    echo "2. detect i2c devices (better to run over telnet"
    echo "3. i2c read"
    echo "4. usb det_n (flash_ad_17) read"
    echo "5. buttons (power_on, wps, factory reset)"
    echo "6. HW version"
    echo "7. Charger/Gauge - general"
    echo "8. Sleep Counters"
    echo "9. AT Commands"
    echo "a. sdcard"
    echo "z. exit"
    echo "-------------------------------------------"
    echo "Select __"
    read SEL

    case $SEL in
        1) flash_all_leds;;
        2) run_i2cdetect;;
        3) run_i2c_read;;
        4) run_flash_ad17_read;;
        5) run_button;;
        6) run_hw_ver;;
        7) run_charger_gauge_general;;
        8) run_sleep_counters;;
        9) run_some_at_commands;;
        a) run_sd_card;;
        z) echo "exit"; exit;;
        *) echo "invalid number [$SEL]"
    esac
done




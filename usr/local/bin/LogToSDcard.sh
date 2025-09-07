#!/bin/sh

if [ "$#" -eq 0 ]; then

    uci set /etc/config/service.LogToSDCard.Enabled=true
    echo ">>> Log To SD Card: Enabled"

elif [ "$#" -eq 1 ]; then

    if [ $1 = 'false' ]; then

        uci set /etc/config/service.LogToSDCard.Enabled=false
        echo ">>> Log To SD Card: Disabled"

    else

        uci set /etc/config/service.LogToSDCard.Enabled=true
        echo ">>> Log To SD Card: Enabled"

    fi

else

    echo ">>> Parameter is wrong"

fi

exit 0

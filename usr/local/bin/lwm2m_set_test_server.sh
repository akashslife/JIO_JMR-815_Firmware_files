#!/bin/sh

SCRIPT="lwm2m_server_config.sh"
LOG_FILE="/tmp/logs/lwm2m-config.log"

#CMD section 
CMD=CMD
CLEAR=CLEAR
ADD=ADD
SHOW=SHOW
HELP=HELP

#PARAMS:

# --Mandatory Parameters--
URI=URI
#   Description: server URI
#        values:       

SEC_ID=SEC_ID
#   Description: PSK Security Id, mandatory only for PSK mode
#        values: for now we support only string of 1-8 bytes 

SEC_KEY=SEC_KEY
#   Description: PSK private key, mandatory only for PSK mode
#        values: for now we support only string of 1-8 bytes 

# --Optionaly Parameters--
BS=BS
FALSE="false"
TRUE="true"
#   Description: is it bootstrap server
#        values: FALSE- Not a bootsrap server
#                TRUE- Bootsrap server
# default Value: FALSE

SEC_MODE=SEC_MODE
#   Description: Security mode
#        values: PSK-    Private shared Key mode
#                NONE- unsecured  mode
# default Value: NONE
PSK=PSK
NONE=NONE

BS_HOLDOFF=BS_HOLDOFF
#   Description: The number of seconds to wait before initiating a Client Initiated Bootstrap 
#                once the LWM2M Client has determined it should initiate this bootstrap mode 
#        values: in seconds
# default Value: 10

LIFETIME=LIFETIME
#   Description: lifetime of the registration 
#        values: in seconds
# default Value: 30 sec
LIFE_TIME_VAL=30

BINDING_MODE=BINDING_MODE
#   Description: lifetime of the registration 
#        values: U
#              : UQ
# default Value: U
BINDING_MODE_VAL=U

IS_BOOTSTRAPPED=IS_BOOTSTRAPPED
SHORT_ID=SHORT_ID
SECURITY_SMS_SERVER_NUMBER=SECURITY_SMS_SERVER_NUMBER

#LOG_LEVEL
#   Description: server short id
#        values: 0-bootstrap
#              : else object instance id +1.
# default Value: U
LOG_LEVEL=LOG_LEVEL
LOG_OFF=0
LOG_ERR=1
LOG_NORMAL=2
LOG_VERBUS=3
LOG_LEVEL_VAL=$LOG_VERBUS

CALC=CALC

LIFETIME_VAL=2592000
CALC_VAL=imei
IS_BOOTSTRAPPED_VAL=false
BINDING_MODE_VAL=UQS
BS_HOLDOFF_VAL=0
SEC_MODE_VAL="${PSK}"
BS_VAL="${FALSE}"  


runScriptWithParams()
{
    local ret=""
    for var in  $*
    do
     eval "value=\$${var}_VAL"
        ret="${ret} ${var}=${value}"
    done
    $SCRIPT $ret
}


clearAllServers()
{
    CMD_VAL=${CLEAR}
    PARAMS="${CMD}"
    runScriptWithParams $PARAMS
}


showAllServers()
{
    CMD_VAL=${SHOW}
    PARAMS="${LOG_LEVEL} ${CMD}"
    runScriptWithParams $PARAMS
}

addBootstrapServer()
{
    CMD_VAL="${ADD}"
    URI_VAL="coaps://54.241.16.47:5684"
    SEC_MODE_VAL="${PSK}"
    SEC_ID_VAL="midas"
    SEC_KEY_VAL="1midas"
    BS_VAL="${TRUE}"
    BS_HOLDOFF_VAL=0
    BINDING_MODE_VAL=U
    CALC_VAL=raw
    SHORT_ID_VAL=0
    PARAMS="${LOG_LEVEL} ${CMD} ${URI} ${SEC_MODE} ${SEC_ID} ${SEC_KEY} ${BS} ${BS_HOLDOFF} ${LIFETIME} ${BINDING_MODE} ${IS_BOOTSTRAPPED} ${CALC} ${SHORT_ID}"
    
    runScriptWithParams $PARAMS
}

addTestServer()
{
    CMD_VAL="${ADD}"
    URI_VAL="coaps://54.241.16.47:5684"
    SEC_MODE_VAL="${PSK}"
    SEC_ID_VAL="midas"
    SEC_KEY_VAL="1midas"
    BS_VAL="${FALSE}"
    BS_HOLDOFF_VAL=0
    BINDING_MODE_VAL=U
    CALC_VAL=raw
    SHORT_ID_VAL=0
    PARAMS="${LOG_LEVEL} ${CMD} ${URI} ${SEC_MODE} ${SEC_ID} ${SEC_KEY} ${BS} ${BS_HOLDOFF} ${LIFETIME} ${BINDING_MODE} ${IS_BOOTSTRAPPED} ${CALC} ${SHORT_ID}"
    
    runScriptWithParams $PARAMS
}


addUnsecuredTestServer()
{
    set -x
    CMD_VAL="${ADD}"
    URI_VAL="coaps://5.39.83.206:5683"
    SEC_MODE_VAL="NONE"
    BS_VAL=false
    BS_HOLDOFF_VAL=0
    BINDING_MODE_VAL=U
    SHORT_ID_VAL=2
    PARAMS="${LOG_LEVEL} ${CMD} ${URI} ${SEC_MODE} ${SEC_ID} ${BS} ${BS_HOLDOFF} ${LIFETIME} ${BINDING_MODE} ${IS_BOOTSTRAPPED} ${CALC} ${SHORT_ID}"
    runScriptWithParams $PARAMS
}

killLwm2mApp()
{
    /etc/init.d/S24lwm2m stop > "/dev/null"
}

showHelp()
{
    CMD_VAL=${HELP}
    PARAMS="${LOG_LEVEL} ${CMD}"
    runScriptWithParams $PARAMS
}


main()
{
    echo "" > $LOG_FILE
    for task in $tasks
    do
      $task >> $LOG_FILE
    done
}

if [ "$1" = "restoreProd" ]
then
	echo -e "restore lwm2m defaults\n"
	/etc/init.d/S24lwm2m stop
	rm -rf /etc/config/lwm2m
	cp -rf /etc/operators/default/config/lwm2m /etc/config
elif  [ "$1" = "server" ]
then
	tasks="killLwm2mApp clearAllServers addUnsecuredTestServer showAllServers"
	main
else
	tasks="killLwm2mApp clearAllServers addBootstrapServer showAllServers"
	main
fi


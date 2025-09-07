#!/bin/sh
#LOCAL_VARIABLES
FAIL=FAIL
SUCCESS=SUCCESS
TRUE="true"
FALSE="false"
EMPTY="null"
INSTANCES_PATH="/nvm/etc/config/lwm2m/obj_instances"
INSTANCES_OPAQUE_PATH="${INSTANCES_PATH}/opaque"
TAMPLATE_PATH="/etc/config/lwm2m/obj_templates"
SERVER_OBJ_ID=1
SECURITY_OBJ_ID=0
ACL_OBJ_ID=2 # TODO handle ACL

#security resources
SECURITY_URI_ID=0
SECURITY_BOOTSTRAP_ID=1
SECURITY_SECURITY_ID=2
SECURITY_PUBLIC_KEY_ID=3
SECURITY_SERVER_PUBLIC_KEY_ID=4
SECURITY_SECRET_KEY_ID=5
SECURITY_SMS_SECURITY_ID=6
SECURITY_SMS_KEY_PARAM_ID=7
SECURITY_SMS_SECRET_KEY_ID=8
SECURITY_SMS_SERVER_NUMBER_ID=9
SECURITY_SHORT_SERVER_ID=10
SECURITY_HOLD_OFF_ID=11
SECURITY_IS_BOOTSTRAPPED_ID=30000

#server resources
SERVER_SHORT_ID_ID=0
SERVER_LIFETIME_ID=1
SERVER_MIN_PERIOD_ID=2
SERVER_MAX_PERIOD_ID=3
SERVER_DISABLE_ID=4
SERVER_TIMEOUT_ID=5
SERVER_STORING_ID=6
SERVER_BINDING_ID=7
SERVER_UPDATE_ID=8

#default falues
SERVER_LIFETIME=2592000
SERVER_MIN_PERIOD=1
SERVER_MAX_PERIOD=60
SERVER_TIMEOUT=86400
SERVER_STORING="${TRUE}"
SERVER_BINDING="UQ"

#script parameters

CMD=${HELP}
#   Description: script mode
#        values: CLEAR-clean all servers data
#                ADD-  add new server
#                SHOW-  all server data
# default Value: SHOW   
CLEAR=CLEAR
ADD=ADD
SHOW=SHOW
HELP=HELP

CALC=raw

#lwm2m parameters
# --Mandatory Parameters--
#  URI
#   Description: server URI
#        values:       


#SEC_ID
#   Description: PSK Security Id, mandatory only for PSK mode
#        values: for now we support only string of 1-8 bytes 

#SEC_KEY
#   Description: PSK private key, mandatory only for PSK mode
#        values: for now we support only string of 1-8 bytes 

# --Optionaly Parameters--
#BS
#   Description: is it bootstrap server
#        values: FALSE- Not a bootsrap server
#                TRUE- Bootsrap server
# default Value: FALSE
BS=$FALSE

#SEC_MODE
#   Description: Security mode
#        values: PSK-    Private shared Key mode
#                NONE- unsecured  mode
# default Value: NONE
PSK=PSK
NONE=NONE
SEC_MODE=$NONE

#BS_HOLDOFF
#   Description: The number of seconds to wait before initiating a Client Initiated Bootstrap 
#                once the LWM2M Client has determined it should initiate this bootstrap mode 
#        values: in seconds
# default Value: 10
BS_HOLDOFF=10

#LIFETIME
#   Description: lifetime of the registration 
#        values: in seconds
# default Value: 30 sec
LIFETIME=30

#BINDING_MODE
#   Description: lifetime of the registration 
#        values: U
#              : UQ
# default Value: U
BINDING_MODE=U

#SHORT_ID
#   Description: server short id
#        values: 0-bootstrap
#              : else object instance id +1.
# default Value: U
SHORT_ID=0

IS_BOOTSTRAPPED=0
SECURITY_SMS_SERVER_NUMBER="null"
#LOG_LEVEL
#   Description: server short id
#        values: 0-bootstrap
#              : else object instance id +1.
# default Value: U
LOG_OFF=0
LOG_ERR=1
LOG_NORMAL=2
LOG_VERBUS=3
LOG_LEVEL=$LOG_NORMAL

parseArg()
{
    local argVarName=$1
    local value=$2
    printMsgVerbus "value=<${value}>"
    eval "${argVarName}=${value}" #set var as string name
    printMsgVerbus "--${argVarName}=${value}--"
}

parseScriptArgs()
{
    local args=$(echo "$*" | tr " " "\n" | tr "\n" " " )
    for var in  $args #loop over argv/argc 
    do
        ARG=$(echo $var | awk 'BEGIN { FS = "=" } ; { print $1 }')
        VAL=$(echo $var | awk 'BEGIN { FS = "=" } ; { print $2 }')
        parseArg "${ARG}" "${VAL}"
    done
}

printMsg()
{
    msg=$1
    level=$2
   
    if [ $LOG_LEVEL -ge $level ]
    then
        if [ "${LOG_VERBUS}" = "${level}" ]
        then
            case "$level" in
                "${LOG_ERR}")    lstr="[E]" ;;
                "${LOG_NORMAL}") lstr="[N]" ;;
                "${LOG_VERBUS}") lstr="[V]" ;;
            esac
            echo "${lstr} ${msg}"
        else
            echo "${msg}"
        fi
    fi
}

printMsgErr()
{
    printMsg "$1" "${LOG_ERR}"
}

printMsgNormal()
{
    printMsg "$1" "${LOG_NORMAL}"
}

printMsgVerbus()
{
    printMsg "$1" "${LOG_VERBUS}"
}


verifyBootstrapParam()
{
    local retVarName=$1
     eval "$retVarName=${SUCCESS}"
    #verify bootstrap  mode
    if  [ "${BS}" = "${TRUE}" ] ; then
        SECURITY_BOOTSTRAP=$BS
    elif  [ "${BS}" = "${FALSE}" ] ; then
        SECURITY_BOOTSTRAP=$BS
    else
        printMsgVerbus"BS is ${BS}= should be true/false"
        eval "$retVarName=${FAIL}"
    fi
}

verifySecurityParam()
{
    local retVarName=$1
     eval "$retVarName=${SUCCESS}"
     
    if [ "${SEC_MODE}" = "${PSK}" ] ; then # secure mode, verify mandatory key material
        SECURITY_SECURITY=0 #PSK
        #verify security id
        if [  "${CALC}" = "raw" ] || [  "${CALC}" = "hex" ]
        then
            if [ "$SEC_ID" = "" ] ; then  
                printMsgVerbus "SEC_ID is empty"
                eval "$retVarName=${FAIL}"
            elif [ "$SEC_KEY" = "" ] ; then 
                printMsgVerbus  "SEC_KEY is empty"
                eval "$retVarName=${FAIL}"
            else
                SECURITY_PUBLIC_KEY=$SEC_ID
                SECURITY_SECRET_KEY=$SEC_KEY
                printMsgVerbus "SECURITY_SECRET_KEY=${SECURITY_SECRET_KEY}"
                printMsgVerbus "SECURITY_PUBLIC_KEY=${SECURITY_PUBLIC_KEY}"
            fi
        fi
        SECURITY_SECRET_CALC=$CALC
    elif [ "${SEC_MODE}" = "${NONE}" ] ; then 
        SECURITY_SECURITY=3 #unsecured mode
    else
        printMsgVerbus  "SEC_MODE is ${SEC_MODE}= should be ${NONE}/${PSK}"
        eval "$retVarName=${FAIL}"
    fi
}

verifyBindingModeParam()
{
    local retVarName=$1
    eval "$retVarName=${SUCCESS}"
    if  [ "${BINDING_MODE}" = "U" ] ; then
        SERVER_BINDING="U"
    elif  [ "${BINDING_MODE}" = "UQ" ] ; then
        SERVER_BINDING="UQ"
    elif  [ "${BINDING_MODE}" = "UQS" ] ; then
        SERVER_BINDING="UQS"
    else
        printMsgVerbus  "BINDING_MODE is ${BINDING_MODE}= should be U/UQ/UQS"
        eval "$retVarName=${FAIL}" 
    fi
}

setLocalObjectFields()
{
    local retVarName=$1
    local tmpRet=""
    eval "$retVarName=${FAIL}"
    if  [ "$CMD" = "${ADD}" ] ; then
         if [ "$URI" = "" ] ; then  # ADD
            printMsgVerbus "URI is empty"
            return -1
         fi
         SECURITY_URI=$URI
         SECURITY_IS_BOOTSTRAPPED="$IS_BOOTSTRAPPED"
         printMsgVerbus "SECURITY_URI=${SECURITY_URI}" $LOG_VERBUS
         
        #verify bootstrap  mode
        verifyBootstrapParam tmpRet
        if [ "$tmpRet" = "${FAIL}" ] ; then
            eval "$retVarName=${FAIL}"
            return -1
        fi
        printMsgVerbus "SECURITY_BOOTSTRAP=${SECURITY_BOOTSTRAP}"
        printMsgVerbus "SECURITY_SHORT_SERVER=${SECURITY_SHORT_SERVER}"
        
        verifySecurityParam tmpRet
        if [ "$tmpRet" = "${FAIL}" ] ; then
            eval "$retVarName=${FAIL}"
            return -1
        fi
        printMsgVerbus "SECURITY_SECURITY=${SECURITY_SECURITY}"
         
        verifyBindingModeParam tmpRet
        if [ "$tmpRet" = "${FAIL}" ] ; then
            eval "$retVarName=${FAIL}"
            return -1
        fi
         printMsgVerbus "SERVER_BINDING=${SERVER_BINDING}"
         
         #server parameters
         SECURITY_HOLD_OFF=$BS_HOLDOFF
         SERVER_LIFETIME=$LIFETIME
    fi
    eval "$retVarName=${SUCCESS}"
}

printParam()
{
    local args=$(echo "$*" | tr " " "\n" | sort -u | tr "\n" " " )
    for param in $args #loop over argv/argc 
    do
        eval "value=\$$param"
        if [ ! "${value}" = "" ] ; then 
            printMsgVerbus "$param=$value"
            value=""
        fi
    done
}

printLocalObjectFields()
{
    printParam CMD SECURITY_URI SECURITY_BOOTSTRAP SECURITY_SECURITY SECURITY_PUBLIC_KEY  SECURITY_SECRET_KEY SECURITY_HOLD_OFF SERVER_LIFETIME SERVER_BINDING   IS_BOOTSTRAPPED SHORT_ID SECURITY_SMS_SERVER_NUMBER
}

uciSet()
{
    local File=$1
    local entry=$2
    local value=$3
    local uci_entry="${File}.${entry}"
    uci -c "${INSTANCES_PATH}" set "${uci_entry}"="$value"
    uci -c "${INSTANCES_PATH}" commit "${File}"
}

uciGet()
{
    local File=$1
    local entry=$2
    local retArg=$3
    local uci_entry="${File}.${entry}"
    local value=$(uci -c "${INSTANCES_PATH}" get "${uci_entry}")
    if [ "${retArg}" = "" ] ; then
        echo "${value}"
    else
        eval "$retArg=${value}"
    fi
    
}

setInstancesInfo()
{
    local objId=$1
    local value=$2
    uciSet "instances_info" "${objId}.instances"  "${value}"
}


setInstanceResource()
{
    local object=$1
    local instance=$2
    local resource=$3
    local value=""
    eval "resourceId=\$${resource}_ID"
    eval "value=\$$resource"
    printMsgVerbus "set ${object}/${instance}/${resourceId}=${value}"
    
    uciSet "${object}_${instance}" "${resourceId}.value" "${value}"  
}

setMultiInstanceResource()
{
    local object=$1
    local instance=$2
    local resource=$3
    local resourceInstance=$4
    local value=$5
    printMsgVerbus "set ${object}/${instance}/${resource}/${resourceInstance}=${value}"
    
    uciSet "${object}_${instance}" "${resource}.${resourceInstance}" "${value}" 
}

setInstanceResourceOpaq()
{
    local object=$1
    local instance=$2
    local resourceName=$3
    eval "resourceId=\$${resourceName}_ID"
    eval "value=\$$resourceName"
    size=${#value}
    OPAQUE_FILE="${object}_${instance}_${resourceId}.opaque"
    uciSet "${object}_${instance}" "${resourceId}.FileName" "${OPAQUE_FILE}"
    uciSet "${object}_${instance}" "${resourceId}.DataSize" "${size}"
    echo "$value" > "${INSTANCES_OPAQUE_PATH}/${OPAQUE_FILE}"
    printMsgVerbus "value=${value}:${size}"
}

setCalc()
{
    local object=$1
    local instance=$2
    local resourceName=$3

    if [ "${CALC}" = "imei" ]
    then
        uciSet "${object}_${instance}" "${SECURITY_PUBLIC_KEY_ID}.calc" "raw"
        uciSet "${object}_${instance}" "${SECURITY_SECRET_KEY_ID}.calc" "md5ImeiHex"
    elif [ "${CALC}" = "hex" ]
    then
        uciSet "${object}_${instance}" "${SECURITY_PUBLIC_KEY_ID}.calc" "raw"
        uciSet "${object}_${instance}" "${SECURITY_SECRET_KEY_ID}.calc" "hex"
    else
        uciSet "${object}_${instance}" "${SECURITY_PUBLIC_KEY_ID}.calc" "raw"
        uciSet "${object}_${instance}" "${SECURITY_SECRET_KEY_ID}.calc" "raw"
    fi

}

getInstanceResource()
{
    local object=$1
    local instance=$2
    local resourceName=$3
    local returnValue=$4
    eval "resourceId=\$${resourceName}_ID"

    uciGet "${object}_${instance}" "${resourceId}.value" "${returnValue}"
}

printInstanceResource()
{
    local object=$1
    local instance=$2
    local resourceName=$3
    VAL=$4
    eval "ID=\$${resourceName}_ID"
    getInstanceResource $object $instance $resourceName VAL
    printAlign "${object}/${instance}/${ID}" 10 "${resourceName}=" 20 "${VAL}" 0
}

getInstanceResourceOpaq()
{
    local object=$1
    local instance=$2
    local resourceName=$3
    local VAL=$4
    local SIZE=$5
    local value=""
    eval "ID=\$${resourceName}_ID"
    uciGet "${object}_${instance}" "${ID}.FileName" "OPAQUE_FILE"
    uciGet "${object}_${instance}" "${ID}.DataSize" "OPAQUE_SIZE"
    value="$(cat ${INSTANCES_OPAQUE_PATH}/${OPAQUE_FILE})"
    chmod  777 "${INSTANCES_OPAQUE_PATH}/${OPAQUE_FILE}"
    eval "$VAL=${value}"
    eval "$SIZE=${OPAQUE_SIZE}"
}

printAlign()
{
    local state="arg"
    local ret=""
    for var in "$@" #loop over argv/argc 
    do
        if [ "${state}" == "arg" ] ; then
            printValue=$var
            state="size"
        else
            printSize=$var
            state="arg"
            ret=$(printf "%s%-${printSize}s" "${ret}" "${printValue}" ) 
        fi
    done
    printf "${ret}\n"
}

printInstanceResourceOpaq()
{	
    local object=$1
    local instance=$2
    local resourceName=$3
    
    eval "ID=\$\{${resourceName}_ID\}"
    getInstanceResourceOpaq $1 $2 $3 val size
    printAlign "${object}/${instance}/${ID}" 10 "${resourceName}" 20 "${val}:${size}" 0
}


getInstancesInfo()
{
    local object=$1
    uciGet "instances_info" "${object}.instances"
}

cleanServersData()
{
    setInstancesInfo "${SERVER_OBJ_ID}" "${EMPTY}"
    setInstancesInfo "${SECURITY_OBJ_ID}" "${EMPTY}"
    find "${INSTANCES_PATH}" -type f -name "${SECURITY_OBJ_ID}_*" -exec rm {} \;
    find "${INSTANCES_PATH}" -type f -name "${SERVER_OBJ_ID}_*" -exec rm {} \;
    printMsgVerbus "err=$?"
}

copyObjectInstance()
{
    local object_id=$1
    local retVarName=$2
    let instance_id=0
    
    inst=$(getInstancesInfo "${object_id}")
    printMsgVerbus "inst=${inst}"
    if [ ! "${inst}" = "${EMPTY}" ] ; then
        instances_n=$(echo $inst | tr ";" "\n")
        printMsgVerbus "instances_n=${instances_n}"
        for in in $instances_n; do
            printMsgVerbus "$object_id=$in"
            let instance_id++
        done
    fi
    
    printMsgVerbus "new instanceid=$instance_id"
    if [ "${instance_id}" = "0" ] ; then
        setInstancesInfo "${object_id}" "${instance_id}"
    else
        setInstancesInfo "${object_id}" "${inst};${instance_id}"  
    fi
    
    cp "${TAMPLATE_PATH}/${object_id}" "${INSTANCES_PATH}/${object_id}_${instance_id}"
    chmod  777 "${INSTANCES_PATH}/${object_id}_${instance_id}" 
    sync
    eval "$retVarName=${instance_id}"
}

addServer()
{
    SRV_RET_ARG=$1
    local ret="0"
    copyObjectInstance "${SECURITY_OBJ_ID}" "sec_inst_id"
    copyObjectInstance "${SERVER_OBJ_ID}" "srv_inst_id"
    printMsgVerbus "sec_inst_id=$sec_inst_id"
    
           SECURITY_SHORT_SERVER="${SHORT_ID}"
           SERVER_SHORT_ID="${SHORT_ID}"
        
     

        
        SERVER_SHORT_ID=${SECURITY_SHORT_SERVER} #need to set also server short id
    
        setInstanceResource "${SERVER_OBJ_ID}" "${srv_inst_id}" "SERVER_SHORT_ID"
        setInstanceResource "${SERVER_OBJ_ID}" "${srv_inst_id}" "SERVER_LIFETIME"
        setInstanceResource "${SERVER_OBJ_ID}" "${srv_inst_id}" "SERVER_BINDING"
    
    if [ "${ret}" = "0" ] ; then
        setInstanceResource "${SECURITY_OBJ_ID}" "${sec_inst_id}" "SECURITY_URI"
        setInstanceResource "${SECURITY_OBJ_ID}" "${sec_inst_id}" "SECURITY_SHORT_SERVER"
        setInstanceResource "${SECURITY_OBJ_ID}" "${sec_inst_id}" "SECURITY_BOOTSTRAP"
        setInstanceResource "${SECURITY_OBJ_ID}" "${sec_inst_id}" "SECURITY_SECURITY"
        setInstanceResource "${SECURITY_OBJ_ID}" "${sec_inst_id}" "SECURITY_HOLD_OFF"
    	setMultiInstanceResource 0 0 30000 1 "${IS_BOOTSTRAPPED}"
        setInstanceResource "${SECURITY_OBJ_ID}" "${sec_inst_id}" "SECURITY_SMS_SERVER_NUMBER"

        if [ "${SECURITY_SECURITY}" = "0" ] 
        then
            if [ "${CALC}" = "hex" ] || [ "${CALC}" = "raw" ]
            then
                setInstanceResourceOpaq "${SECURITY_OBJ_ID}" "${sec_inst_id}" "SECURITY_PUBLIC_KEY"
                setInstanceResourceOpaq "${SECURITY_OBJ_ID}" "${sec_inst_id}" "SECURITY_SECRET_KEY"
            fi
        fi
         
        setCalc "${SECURITY_OBJ_ID}" "${sec_inst_id}" "SECURITY_SECRET_KEY"
    fi
    
    if [ "${ret}" = "0" ] ; then
        eval "$SRV_RET_ARG=${SUCCESS}"
    else
        printMsgVerbus  "ret=$ret" 
        eval "$SRV_RET_ARG=${FAIL}"
    fi
}

showServer()
{
    local inst=$(getInstancesInfo "${SECURITY_OBJ_ID}")
    if [ ! "${inst}" = "${EMPTY}" ] ; then
        instances_n=$(echo $inst | tr ';' '\n')
        for instanceId in $instances_n; do
            printInstanceResource "${SECURITY_OBJ_ID}" "${instanceId}" "SECURITY_URI"
            #printInstanceResource "${SECURITY_OBJ_ID}" "${instanceId}" "SECURITY_BOOTSTRAP"
            getInstanceResource "${SECURITY_OBJ_ID}" "${instanceId}" "SECURITY_BOOTSTRAP" "SECURITY_BOOTSTRAP"
            printInstanceResource "${SECURITY_OBJ_ID}" "${instanceId}" "SECURITY_SECURITY"
            
            getInstanceResource "${SECURITY_OBJ_ID}" "${instanceId}" "SECURITY_SECURITY" "SECURITY_SECURITY"
            if [ "${SECURITY_SECURITY}" = "0" ] ; then
            	if [ "${CALC}" = "raw" ] || [ "${CALC}" = "hex" ]
            	then
                    printInstanceResourceOpaq "${SECURITY_OBJ_ID}" "${instanceId}" "SECURITY_PUBLIC_KEY"
                    printInstanceResourceOpaq "${SECURITY_OBJ_ID}" "${instanceId}" "SECURITY_SECRET_KEY"
            	fi
            fi
            printInstanceResource "${SECURITY_OBJ_ID}" "${instanceId}" "SECURITY_SHORT_SERVER"
            
            if  [ "${SECURITY_BOOTSTRAP}" = "${FALSE}" ] ; then
               printInstanceResource "${SERVER_OBJ_ID}" "${instanceId}"   "SERVER_SHORT_ID"
               printInstanceResource "${SERVER_OBJ_ID}" "${instanceId}"   "SERVER_LIFETIME"
               printInstanceResource "${SERVER_OBJ_ID}" "${instanceId}"   "SERVER_BINDING"
            fi
        done
    fi
    printMsgVerbus "${SUCCESS}"
}



show_help()
{
    printf "usage: %s %s" "$(basename $0)" 'PARAM=VALUE PARAM=VALUE...

where PARAM:
    [CMD]
        VALUE: <ADD>-add server
               <CLEAR>-remove all servers
               <SHOW>-all server data
               <HELP>-show this help
    [URI]
        VALUE: <server URI>
        
    [BS]-is it bootstrap server
        VALUE: <true>- Bootsrap server
               <false>-Not a bootsrap server
               
    [SEC_MODE]
        VALUE: <PSK>-Private shared Key mode
               <NONE>-unsecured  mode
               
    [SEC_ID]-PSK private key, mandatory only for PSK mode
        VALUE: <PSK Security Id>
    
    [SEC_KEY]-PSK private key, mandatory only for PSK mode
        VALUE: <PSK private key>- for now we support only string of 1-8 bytes 
        
    [BS_HOLDOFF]-The number of seconds to wait before initiating a Client Initiated Bootstrap 
                 once the LWM2M Client has determined it should initiate this bootstrap mode 
        VALUE: <wait time>- in seconds
      DEFAULT:10 seconds
      
    [LIFETIME]-lifetime of the registration
        VALUE: <life time>- in seconds
      DEFAULT:86400 seconds(1 day)
   
   [BINDING_MODE]-lifetime of the registration
        VALUE: <U>-  udp binding mode
               <UQ>- udp with queue binding mode
      DEFAULT:U
   
  [SHORT_ID]- server short id
        VALUE: <0>-bootstrap
               < val>0>- udp and queue binding mode
      DEFAULT:object instance id +1.
  [LOG_LEVEL]- log level
        VALUE: <0>- no logs
               <1>- print only errors
               <2>- print normal
               <3>- print verbose
      DEFAULT:2
      
example usage:

show all servers-
    lwm2m_server_config.sh CMD=SHOW
    
clear all servers-
    lwm2m_server_config.sh CMD=CLEAR
    
help-
    lwm2m_server_config.sh CMD=HELP
    
add server-
    lwm2m_server_config.sh CMD=ADD URI="coaps://5.39.83.206:5683" SEC_MODE=PSK BS=true BS_HOLDOFF=10 LIFETIME=10 BINDING_MODE=U'
            
    printMsgNormal $usage
}
VER="1.0.0"

main()
{
    printMsgVerbus "ver=${VER}"
    parseScriptArgs "$*"
    
    setLocalObjectFields ret
    if [ ! "${ret}" = "${SUCCESS}" ] ; then
       printMsgVerbus  "failed to validate: err: ${ret}"
       printMsgErr   "result=fail"
       show_help
       exit
    fi
    printLocalObjectFields
    printMsgVerbus "args validation pass"
    
    if [ "${CMD}" = "${CLEAR}" ] ; then
        cleanServersData
        printMsgVerbus "clear ...ok"
    elif [ "${CMD}" = "${ADD}" ] ; then
        addServer SRV_RET_ARG
        if [ ! "${SRV_RET_ARG}" = "${SUCCESS}" ] ; then
            printMsgVerbus  "failed to addServer: err: ${SRV_RET_ARG}"
            printMsgErr   "result=fail"
            exit 
        fi
        printMsgVerbus "addServer ...ok"
    elif [ "${CMD}" = "${SHOW}" ] ; then
        showServer
    else
        show_help
    fi
    
    printMsgNormal "result=ok"
}

main "$*"

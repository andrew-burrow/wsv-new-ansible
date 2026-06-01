#!/bin/bash

##################################################################
# Copyright 2005 - 2010 IT Shared Solutions
# 222 Exhibition Street, Melbourne, VIC 3000, Australia.
# All rights reserved. 
# This software is the confidential and proprietary information of 
# Victorian Workcover Authority.
#
# This script is used to manage Queue Manager certificates.
# 
# Date Created:	08/09/2016
# Author:	Hemesh Kumar
#
##################################################################
#
#                       C H A N G E   L O G                       
#
# Version  Date        Author     Comment
# ================================================================
# 1.0.0    08/09/2016  H Kumar    Initial version.
# 1.0.1    20/12/2016  N Casey    Create new option (2).
# 1.0.2    21/11/2017  H Kumar    Changes made to make ouptput
#                                 splunk friendly.
#
##################################################################



#########################################################
#
#       F U N C T I O N S
#
#########################################################

usage()
{
  echo "USAGE: $(basename $0) <option>"
  echo "  R - Retrieve Certificate Info"
  echo "  U - Update expired certificates"
  echo "  F - Update expired certificates and certificates due to expire in 30 Days" 
  echo "  2 - Update all certificates - for SHA2 CA replacement"
}

doExec()
{
     cmd=$1
     echo "performing: $cmd" >&2
     su $MQMUSR -c "$cmd"
     if [ $? -ne 0 ]; then
       echo "ERROR executing command: ${cmd}" >&2
       echo "Exiting script..." >&2
       exit 1
     fi
}

qmgrExists()
{
  dspmq -m "$1" > /dev/null 2>&1

  return $?
}

qmgrStatus()
{
  local QMGRNAME=$1
  dspmq -m ${QMGRNAME} | sed 's/.*STATUS(\(.*\))/\1/'
}

getEnvironments()
{
  if [ "$HOST" == "sxuwmq0101" ] || [ "$HOST" == "sxuwmq0201" ] || [ "$HOST" == "sxuiib0101" ] || [ "$HOST" == "sxuiib0201" ] || [ "$HOST" == "sxuibr0201" ] ; then
    ENVS=( \
      "sp1" \
      "sp2" \
      "sp3" \
      )
  elif [ "$HOST" == "sduwmq0101" ] || [ "$HOST" == "sduwmq0201" ] || [ "$HOST" == "sduiib0101" ] || [ "$HOST" == "sduiib0201" ] || [ "$HOST" == "sduibr0201" ] ; then
    ENVS=( \
      "ci1" \
      "dv1" \
      "ps1" \
      )
  elif [ "$HOST" == "stuwmq0101" ] || [ "$HOST" == "stuwmq0201" ] || [ "$HOST" == "stuiib0101" ] || [ "$HOST" == "stuiib0201" ] || [ "$HOST" == "stuibr0201" ] ; then
    ENVS=( \
      "ts1" \
      "ts2" \
      "ts3" \
      )
  elif [ "$HOST" == "svuwmq0101" ] || [ "$HOST" == "svuwmq0201" ] || [ "$HOST" == "svuiib0101" ] || [ "$HOST" == "svuiib0201" ] || [ "$HOST" == "svuibr0201" ] ; then
    ENVS=( \
      "sv1" \
      )
  elif [ "$HOST" == "sauwmq0101" ] || [ "$HOST" == "sauwmq0201" ] || [ "$HOST" == "sauiib0101" ] || [ "$HOST" == "sauiib0201" ] || [ "$HOST" == "sauibr0201" ] ; then
    if [ "${OPTION}" == "U" ] || [ "${OPTION}" == "F" ] || [ "${OPTION}" == "2" ] ; then
      echo "Unsupported Option: This environment only supports R as parameter option"
      exit 1
    fi

    ENVS=( \
      "pa1" \
      "tr1" \
      )
  elif [ "$HOST" == "spuwmq0101" ] || [ "$HOST" == "spuwmq0201" ] || [ "$HOST" == "spuiib0101" ] || [ "$HOST" == "spuiib0201" ] || [ "$HOST" == "spuibr0201" ] ; then
    if [ "${OPTION}" == "U" ] || [ "${OPTION}" == "F" ] || [ "${OPTION}" == "2" ] ; then
      echo "Unsupported Option: This environment only supports R as parameter option"
      exit 1
    fi

    ENVS=( \
      "pr1" \
      )
  else
    echo "Unsupported host: ${HOST}"
    exit 1
  fi
}

getQueueManagers()
{
  ENV=${1^^}
  if [ "$T" == "M" ] ; then
    QMGRS=( \
      "${ENV}${E}F${SITE}" \
      "${ENV}${E}G${SITE}" \
      "${ENV}${E}M${SITE}" \
      "${ENV}${E}L${SITE}" \
    )
  elif [ "$T" == "I" ] ; then
    QMGRS=( \
      "${ENV}${E}I${SITE}" \
      "${ENV}${E}J${SITE}" \
    )
  elif [ "$T" == "B" ] ; then
    QMGRS=( \
      "${ENV}${E}B${SITE}" \
    )
  fi
}

getCertificateExpiry()
{
  local QMGR=$1
  local qmgrname=${QMGR,,}
  local QMGR_DIR=/var/mqm/qmgrs/${QMGR}/ssl
  local RETVAL=0

  qmgrExists ${QMGR}
  
  if [ $? -eq 0 ]; then
    local EXPIRY_DATETIME=$(runmqakm -fips -cert -details -label ibmwebspheremq${qmgrname} -db ${QMGR_DIR}/key.kdb -pw "`cat ${QMGR_DIR}/key.passwd`" | grep "Not After" | cut -c13-)
    local EXPIRY_DATE=$(date -d "${EXPIRY_DATETIME}" '+%Y-%b-%d')
    getTimeToExpire "${EXPIRY_DATETIME}"
    
    if [ "${DAYS_TO_EXPIRE}" -le '0' ] ; then
      log "E" ${QMGR} ${EXPIRY_DATE} ${DAYS_TO_EXPIRE}
      RETVAL=2
    elif [ "${DAYS_TO_EXPIRE}" -le "${EXPIRY_THRESHOLD}" ] ; then
      log "W" ${QMGR} ${EXPIRY_DATE} ${DAYS_TO_EXPIRE}
      RETVAL=1
    else
      log "I" ${QMGR} ${EXPIRY_DATE} ${DAYS_TO_EXPIRE}
    fi
  else
    log "E" ${QMGR} "NA" "NA"
    RETVAL=-1
  fi
  
   if [ ${RETVAL} -eq 0 ]; then
      return ${RETVAL}
   fi
}

getTimeToExpire()
{
  local _expiryDate=`date -d "$1" +%s`
  local _now=`date +%s`
  local _remaining=$(($_expiryDate - $_now))
  local _secperday=$((24 * 3600))
  local _secperweek=$((7 * _secperday))
  local _secperyear=$((52 * _secperweek))
  
  local _year=0
  local _week=0
  local _day=0
  local _hour=0
  local _min=0
  local _sec=0
  
  DAYS_TO_EXPIRE=$(($_remaining / $_secperday))

  if [ "$_remaining" -ge "$_secperyear" ]; then
    _year=$((_remaining/_secperyear))
    _remaining=$((_remaining - (_year * _secperyear)))
  fi

  if [ "$_remaining" -ge "$_secperweek" ]; then
    _week=$((_remaining/_secperweek))
    _remaining=$((_remaining - (_week * _secperweek)))
  fi
  
  if [ "$_remaining" -ge "$_secperday" ]; then
    _day=$((_remaining/_secperday))
    _remaining=$((_remaining - (_day * _secperday)))
  fi
  
  if [ "$_remaining" -ge 3600 ]; then
    _hour=$((_remaining/3600))
    _remaining=$((_remaining - (_hour * 3600)))
  fi

  if [ "$_remaining" -ge 60 ]; then
    _min=$((_remaining/60))
    _remaining=$((_remaining - (_min * 60)))
  fi
  
  _sec=$_remaining
  
  TIME_TO_EXPIRE="$(printf %02d $_year) Years $(printf %02d $_week) Weeks $(printf %02d $_day) Days $(printf %02d $_hour) Hours $(printf %02d $_min) Minutes $(printf %02d $_sec) Seconds"
}

updateCertificate()
{
  local QMGR=$1

  if [ "${OPTION}" != "2" ] ; then
    getCertificateExpiry ${QMGR}
    local RETVAL=$?
  
    if [ $RETVAL -eq 0 ] ; then
      return 0
    elif [ $RETVAL -eq 1 ] && [ "${OPTION}" != "F" ] ; then
      return 0
    fi
  fi

  
  local qmgrname=${QMGR,,}
  local QMGR_DIR=/var/mqm/qmgrs/${QMGR}/ssl

  if [ -f /var/mqm/qmgrs/${QMGR}/ssl/ca.properties ] ; then
    source /var/mqm/qmgrs/${QMGR}/ssl/ca.properties
  else
    echo "ca access information file (ca.properties) is missing"
    return 1
  fi
  
  if [ ! -f ${QMGR_DIR}/${qmgrname}.req ] ; then
    echo "Certificate request does not exist for QMGR: ${QMGR}"
    return 1
  fi
  
  if [ ! -f ${CACREDS} ] ; then
    echo "CA Identity private key does not exist for QMGR: ${QMGR}"
    return 1
  fi

  if [ "$(qmgrStatus ${QMGR})" == "Running" ]; then
    doExec "endmqm -w ${QMGR}"
  fi

  mv ${QMGR_DIR}/${qmgrname}.cer ${QMGR_DIR}/${qmgrname}.cer_${CURDATE}.old
  cat ${QMGR_DIR}/${qmgrname}.req | ( ssh ${CAUSER}@${CASERVER} -oStrictHostKeyChecking=no -q -i ${CACREDS} "vwaCA/sign ${qmgrname} -q" ) > ${QMGR_DIR}/${qmgrname}.cer
  chown mqm:mqm ${QMGR_DIR}/${qmgrname}.cer
  chmod 600 ${QMGR_DIR}/${qmgrname}.cer
  
  runmqakm -fips -cert -receive -file ${QMGR_DIR}/${qmgrname}.cer -db ${QMGR_DIR}/key.kdb -stashed

  doExec "strmqm ${QMGR}"
}

log()
{
  local logLevel=$1
  local qmgr=$2
  local expiryDt=$3
  local daysToExpire=$4

  if [ "${LOG_ENDPOINT}" == "SPLUNK" ] ; then
    echo -e "[`date '+%D %T %Z'`] ${logLevel} QueueManager=${qmgr}, CertificateExpiryDate=${expiryDt}, DaysToExpiry=${daysToExpire}"
  else
    case "${logLevel}" in
      I)
        printf "${GREEN}%s\t%s\t%s${RESET}\n" "${qmgr}" "${expiryDt}" "${daysToExpire}"
        ;;
      W)
        printf "${YELLOW}%s\t%s\t%s${RESET}\n" "${qmgr}" "${expiryDt}" "${daysToExpire}"
        ;;
      E)
        printf "${RED}%s\t%s\t%s${RESET}\n" "${qmgr}" "${expiryDt}" "${daysToExpire}"
        ;;
      *)
        ;;
    esac
  fi
}

#########################################################
#
#       M A I N
#
#########################################################

if [ $(whoami) != "root" ];then
  echo "ERROR: script must be run as root"
  exit 1
fi

OPTION=${1:-S}

if [ "${OPTION}" != "S" ] && [ "${OPTION}" != "R" ] && [ "${OPTION}" != "U" ] && [ "${OPTION}" != "F" ] && [ "${OPTION}" != "2" ] ; then
  usage
  exit 1
fi

RED='\x1b[31m'
GREEN='\x1b[32m'
YELLOW='\x1b[33m'
RESET='\x1b[0m'

if [ "${OPTION}" == "S" ] ; then
  LOG_ENDPOINT=SPLUNK
else
  LOG_ENDPOINT=CONSOLE

  printf "%s\t%s\t%s\n" "Queue Mgr" "Valid Upto" "Time to expire"
fi

HOST=`hostname`
E=$(echo $HOST | cut -c 2 | tr "[:lower:]" "[:upper:]")
T=$(echo $HOST | cut -c 5 | tr "[:lower:]" "[:upper:]")
SITE=$(echo $HOST | cut -c 7-)

CURDATE=`date '+%Y-%b-%d'`

EXPIRY_THRESHOLD=30

MQMUSR="mqm"

declare -a ENVS
declare -a QMGRS

getEnvironments

# Find a working MQ installation location
MQBASE=$(cat /etc/opt/mqm/mqinst.ini | awk -F "=" "/FilePath/ {print \$2}")
for base in $MQBASE ; do
	if [ -x $base/bin/setmqenv ] ; then
		MQBASE=$base
		break
	fi
done

for (( i=0 ; i<${#ENVS[*]} ; i++ )) ; do
  
  getQueueManagers ${ENVS[i]}
  
  # Set the MQ environment to the requested environment name
  source $MQBASE/bin/setmqenv -p /opt/${ENVS[i]}/mqm
  if [ $? -ne 0 ] ; then
    echo "Failed to set MQ environment. Does $env MQ installation exist?"
    exit 1
  fi

  for (( j=0 ; j<${#QMGRS[*]} ; j++ )) ; do
    if [ "$OPTION" == "R" ] || [ "$OPTION" == "S" ] ; then
      getCertificateExpiry ${QMGRS[j]}
    elif [ "$OPTION" == "U" ] || [ "$OPTION" == "F" ] || [ "$OPTION" == "2" ] ; then
      updateCertificate ${QMGRS[j]}
    fi
  done
done


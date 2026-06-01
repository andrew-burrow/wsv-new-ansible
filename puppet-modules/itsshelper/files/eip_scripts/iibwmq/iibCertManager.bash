#!/bin/bash

##################################################################
# Copyright 2016 IT Shared Solutions
# 222 Exhibition Street, Melbourne, VIC 3000, Australia.
# All rights reserved. 
# This software is the confidential and proprietary information of 
# Victorian Workcover Authority.
#
# This script is used to manage Queue Manager certificates.
# 
# Date Created:	21/12/2016
# Author:	Neil Casey (based on mqCertManager.bash by Hemesh Kumar
#
##################################################################
#
#                       C H A N G E   L O G                       
#
# Version  Date        Author     Comment
# ================================================================
# 1.0.1    21/12/2016  N Casey    New script for IIB key management
# 1.0.2    24/11/2017  H Kumar    Changes made to make ouptput
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


getEnvironments()
{
  if [ "$HOST" == "sxuiib0101" ] || [ "$HOST" == "sxuiib0201" ] || [ "$HOST" == "sxuibr0201" ] ; then
    ENVS=( \
      "sp1" \
      "sp2" \
      "sp3" \      
      )
  elif [ "$HOST" == "sduiib0101" ] || [ "$HOST" == "sduiib0201" ] || [ "$HOST" == "sduibr0201" ] ; then
    ENVS=( \
      "ci1" \
      "dv1" \
      "ps1" \
      )
  elif [ "$HOST" == "stuiib0101" ] || [ "$HOST" == "stuiib0201" ] || [ "$HOST" == "stuibr0201" ] ; then
    ENVS=( \
      "ts1" \
      "ts2" \
      "ts3" \
      )
  elif [ "$HOST" == "svuiib0101" ] || [ "$HOST" == "svuiib0201" ] || [ "$HOST" == "svuibr0201" ] ; then
    ENVS=( \
      "sv1" \
      )
  elif [ "$HOST" == "sauiib0101" ] || [ "$HOST" == "sauiib0201" ] || [ "$HOST" == "sauibr0201" ] ; then
    if [ "${OPTION}" == "U" ] || [ "${OPTION}" == "F" ] || [ "${OPTION}" == "2" ] ; then
      echo "Unsupported Option: This environment only supports R as parameter option"
      exit 1
    fi

    ENVS=( \
      "pa1" \
      "tr1" \
      )
  elif [ "$HOST" == "spuiib0101" ] || [ "$HOST" == "spuiib0201" ] || [ "$HOST" == "spuibr0201" ] ; then
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

getIntegrationNodes()
{
  ENV=${1^^}
  if [ "$T" == "I" ] ; then
    INODES=( \
      "IB${ENV}${E}I${SITE}" \
      "IB${ENV}${E}J${SITE}" \
    )
  elif [ "$T" == "B" ] ; then
    INODES=( \
      "IB${ENV}${E}B${SITE}" \
    )
  fi
}

getCertificateExpiry()
{
  local INODE=${1^^}
  local inode=${INODE,,}
  local KEYSTORE=`${IIBBASE}/mqsireportproperties ${INODE} -b webadmin -o HTTPSConnector -r | grep keystoreFile | cut -d "'" -f 2`
  local RETVAL=0

  if [ -f "${KEYSTORE}" ] ; then
    local KEYSTORE_DIR=$(dirname $KEYSTORE)
    local EXPIRY_DATETIME=$(keytool -list -keystore ${KEYSTORE} -storetype jks -storepass "$(cat ${KEYSTORE_DIR}/webadmin.passwd)" -v | \
                          grep "Alias name:\|Entry type:\|\Owner:\|Valid from:"| \
                           awk "/^Owner:/ {OW=\$2}; /^Valid from:/ { if (index(OW, \"iib\")) {print \$7 \" \" \$8 \" \" \$9}} ")
    local EXPIRY_DATE=$(date -d "${EXPIRY_DATETIME}" '+%Y-%b-%d')
    getTimeToExpire "${EXPIRY_DATETIME}"
    
    if [ "${DAYS_TO_EXPIRE}" -le '0' ] ; then
      log "E" ${INODE} ${EXPIRY_DATE} ${DAYS_TO_EXPIRE}
      RETVAL=2
    elif [ "${DAYS_TO_EXPIRE}" -le "${EXPIRY_THRESHOLD}" ] ; then
      log "W" ${INODE} ${EXPIRY_DATE} ${DAYS_TO_EXPIRE}
      RETVAL=1
    else
      log "I" ${INODE} ${EXPIRY_DATE} ${DAYS_TO_EXPIRE}
    fi
  else
    log "E" ${INODE} "NA" "NA"
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
  local INODE=${1^^}

  if [ "${OPTION}" != "2" ] ; then
    getCertificateExpiry ${INODE}
    local RETVAL=$?
  
    if [ $RETVAL -eq 0 ] || [ $RETVAL -eq -1 ] ; then
      return 0
    elif [ $RETVAL -eq 1 ] && [ "${OPTION}" != "F" ] ; then
      return 0
    fi
  fi

  local inode=${INODE,,}
  local KEYSTORE=`${IIBBASE}/mqsireportproperties ${INODE} -b webadmin -o HTTPSConnector -r | grep keystoreFile | cut -d "'" -f 2`
  local KEYSTORE_DIR=$(dirname ${KEYSTORE})

  if [ -f ${KEYSTORE_DIR}/ca.properties ] ; then
    source ${KEYSTORE_DIR}/ca.properties
  else
    echo "ca access information file (ca.properties) is missing"
    return 1
  fi

  # Save existing certificate and request files
  mkdir ${KEYSTORE_DIR}/save_${CURDATE}.old
  chown iibadmin:mqbrkrs ${KEYSTORE_DIR}/save_${CURDATE}.old
  chmod 700 ${KEYSTORE_DIR}/save_${CURDATE}.old
  mv ${KEYSTORE_DIR}/*.cer ${KEYSTORE_DIR}/*.req ${KEYSTORE_DIR}/save_${CURDATE}.old

  local CERTLABEL=$(keytool -list -keystore ${KEYSTORE} -storetype jks -storepass "$(cat ${KEYSTORE_DIR}/webadmin.passwd)" -v | \
                          grep "Alias name:\|Entry type:\|Valid from:" | \
                          awk "/^Entry type:/ {ET=\$3;sub(/^[[:blank:]]*/,\"\",ET);if (ET == \"keyEntry\") {print AN} }; /^Alias name:/ {\$1=\"\";\$2=\"\";AN=\$0;sub(/^[[:blank:]]*/,\"\",AN)}")
  
  #### Create the certificate request file
  ikeycmd -certreq -recreate -target ${KEYSTORE_DIR}/${CERTLABEL}.req -db ${KEYSTORE_DIR}/webadmin.jks -pw $(cat ${KEYSTORE_DIR}/webadmin.passwd) -label ${CERTLABEL}
  if [ ! -f ${KEYSTORE_DIR}/${CERTLABEL}.req ] ; then
    echo "Certificate request does not exist for IIB webadmin"
    return 1
  fi
  
  if [ ! -f ${CACREDS} ] ; then
    echo "CA Identity private key does not exist for IIB webadmin ${KEYSTORE_DIR}"
    return 1
  fi

  cat ${KEYSTORE_DIR}/${CERTLABEL}.req | ( ssh ${CAUSER}@${CASERVER} -oStrictHostKeyChecking=no -q -i ${CACREDS} "vwaCA/sign ${qmgrname} -q" ) > ${KEYSTORE_DIR}/${CERTLABEL}.cer
  chown iibadmin:mqbrkrs ${KEYSTORE_DIR}/${CERTLABEL}.cer ${KEYSTORE_DIR}/${CERTLABEL}.req
  chmod 600 ${KEYSTORE_DIR}/${CERTLABEL}.cer ${KEYSTORE_DIR}/${CERTLABEL}.req
  ikeycmd -cert -receive -file ${KEYSTORE_DIR}/${CERTLABEL}.cer -db ${KEYSTORE_DIR}/webadmin.jks -type jks -pw $(cat ${KEYSTORE_DIR}/webadmin.passwd)

}

log()
{
  local logLevel=$1
  local iNode=$2
  local expiryDt=$3
  local daysToExpire=$4

  if [ "${LOG_ENDPOINT}" == "SPLUNK" ] ; then
    echo -e "[`date '+%D %T %Z'`] ${logLevel} IntegrationNode=${iNode}, CertificateExpiryDate=${expiryDt}, DaysToExpiry=${daysToExpire}"
  else
    case "${logLevel}" in
      I)
        printf "${GREEN}%s\t%s\t%s${RESET}\n" "${iNode}" "${expiryDt}" "${daysToExpire}"
        ;;
      W)
        printf "${YELLOW}%s\t%s\t%s${RESET}\n" "${iNode}" "${expiryDt}" "${daysToExpire}"
        ;;
      E)
        printf "${RED}%s\t%s\t%s${RESET}\n" "${iNode}" "${expiryDt}" "${daysToExpire}"
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

  printf "%s\t%s\t%s\n" "Int Node" "Valid Upto" "Time to expire"
fi

HOST=`hostname`
E=$(echo $HOST | cut -c 2 | tr "[:lower:]" "[:upper:]")
T=$(echo $HOST | cut -c 5 | tr "[:lower:]" "[:upper:]")
SITE=$(echo $HOST | cut -c 7-)

CURDATE=`date '+%Y-%b-%d'`

EXPIRY_THRESHOLD=30

IIBUSR="iibadmin"

declare -a ENVS
declare -a INODES

getEnvironments

# Set up IIB profile, to gain access to java tools. 
for myEnv in ${ENVS[*]} ; do
	if [ -x /opt/$myEnv/iib/server/bin/mqsiprofile ] ; then
		IIBBASE=/opt/$myEnv/iib/server/bin
		break
	fi
done

source $IIBBASE/mqsiprofile


for (( i=0 ; i<${#ENVS[*]} ; i++ )) ; do
  
  getIntegrationNodes ${ENVS[i]}

  for (( j=0 ; j<${#INODES[*]} ; j++ )) ; do
    if [ "$OPTION" == "R" ] || [ "$OPTION" == "S" ] ; then
      getCertificateExpiry ${INODES[j]}
    elif [ "$OPTION" == "U" ] || [ "$OPTION" == "F" ] || [ "$OPTION" == "2" ] ; then
      updateCertificate ${INODES[j]}
    fi
  done
done


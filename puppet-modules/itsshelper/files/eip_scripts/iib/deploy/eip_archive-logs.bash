#!/bin/bash


##################################################################
# Copyright 2005 - 2010 IT Shared Solutions
# 222 Exhibition Street, Melbourne, VIC 3000, Australia.
# All rights reserved. 
# This software is the confidential and proprietary information of 
# Victorian Workcover Authority.
#
# This script archives broker logs.
# 
# Date Created:	19/06/2018
# Author:	Hemesh Kumar
#
##################################################################
#
#                       C H A N G E   L O G                       
#
# Version  Date        Author     Comment
# ================================================================
# 1.0.0    19/06/2018  H Kumar    Initial version.
#
##################################################################



#########################################################
#
#       F U N C T I O N S
#
#########################################################

usage()
{
  echo "USAGE: $(basename $0) -e <environment>"
  echo ""
  echo "  Mandatory Arguments:"
  echo "    -e <environment>                      Specify the environment (ci1|dv1|sv1|ts1|ts2|ts3)"
  echo "    --env <environment>                               ,,                                   "
}

#########################################################
#
#       M A I N
#
#########################################################


###################################
# Get arguments
###################################
while [[ $# -gt 1 ]]
do
key="$1"
echo "${key}"
case $key in
  -e|--env)
  ENVIRONMENT="$2"
  shift
  ;;
  *)
  usage
  ;;
esac
shift
done

CURRENT_DATE=`date +%d-%^b-%Y`

echo "Archive Logs Parameters"
echo "-----------------------"
echo "Environment:  ${ENVIRONMENT}"
echo "Date:         ${CURRENT_DATE}"

if [[ ( -z ${ENVIRONMENT} ) ]]; then
  usage
  exit 1
fi

LAST_MONTH=`date +%Y-%m -d 'last month'`
HOST_NAME=`hostname`

## Archive Log for Broker
LOG_BASE_PATH=/var/iib/${ENVIRONMENT,,}/logs/${LAST_MONTH}
LOG_ARCHIVE_BASE_PATH=/mnt/tpc/logs/${ENVIRONMENT,,}/${HOST_NAME}
LOG_ARCHIVE_PATH=${LOG_ARCHIVE_BASE_PATH}/${LAST_MONTH}

if [ -d "${LOG_BASE_PATH}" ]; then
  if mountpoint -q /mnt/tpc 
  then
    echo "Move ${LOG_BASE_PATH} --> ${LOG_ARCHIVE_PATH}"
    if [ -d "${LOG_ARCHIVE_PATH}" ]; then
      mv -f ${LOG_BASE_PATH}/* ${LOG_ARCHIVE_PATH}/
      chown -R iibadmin:mqbrkrs ${LOG_ARCHIVE_PATH}
      if [ -z "$(ls -A ${LOG_BASE_PATH})"]; then
        echo "Removed ${LOG_BASE_PATH}"
        rm -rf ${LOG_BASE_PATH}
      fi
    else
      mv -f ${LOG_BASE_PATH} ${LOG_ARCHIVE_BASE_PATH}
    fi
  fi
fi

## Archive logs for Jumbo Broker
JUMBO_LOG_BASE_PATH=/var/iib/${ENVIRONMENT,,}jumbo/logs/${LAST_MONTH}
JUMBO_LOG_ARCHIVE_BASE_PATH=/mnt/tpc/logs/${ENVIRONMENT,,}jumbo/${HOST_NAME}
JUMBO_LOG_ARCHIVE_PATH=${JUMBO_LOG_ARCHIVE_BASE_PATH}/${LAST_MONTH}

if [ -d "${JUMBO_LOG_BASE_PATH}" ]; then
  if mountpoint -q /mnt/tpc 
  then
    echo "Move ${JUMBO_LOG_BASE_PATH} --> ${JUMBO_LOG_ARCHIVE_PATH}"
    if [ -d "${JUMBO_LOG_ARCHIVE_PATH}" ]; then
      mv -f ${JUMBO_LOG_BASE_PATH}/* ${JUMBO_LOG_ARCHIVE_PATH}/
      chown -R iibadmin:mqbrkrs ${JUMBO_LOG_ARCHIVE_PATH}
      if [ -z "$(ls -A ${JUMBO_LOG_BASE_PATH})"]; then
        echo "Removed ${JUMBO_LOG_BASE_PATH}"
        rm -rf ${JUMBO_LOG_BASE_PATH}
      fi
    else
      mv -f ${JUMBO_LOG_BASE_PATH} ${JUMBO_LOG_ARCHIVE_BASE_PATH}
    fi
  fi
fi

echo "-----------------------"

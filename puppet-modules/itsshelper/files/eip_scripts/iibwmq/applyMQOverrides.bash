#!/bin/bash

# MQ application overrides script for MQ v8 qmgr.
# Finds installation via /etc/opt/mqm/mqinst.ini
# Sets environment using the discovered installation directory

MQMUSR="mqm"
QMGR_EXISTS=12

usage()
{
  echo "USAGE: $(basename $0) env"
}
  

doExec()
{
     cmd=$1
     # echo "simulating: $cmd"
     # pwd
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
  dspmq -m "$QMGRNAME" > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "true"
  else
    echo "false"
  fi
}

qmgrStatus()
{
  dspmq -m ${QMGRNAME} | sed 's/.*STATUS(\(.*\))/\1/'
}

if [ $# -ne 1 ];then
  usage
  exit 1
fi

if [ $(whoami) != "root" ];then
  echo "ERROR: script must be run as root"
  exit 1
fi

# Collect command line arguments
export ENV=${1^^}
export env=${ENV,,}

# Find a working MQ installation location
MQBASE=$(cat /etc/opt/mqm/mqinst.ini | awk -F "=" "/FilePath/ {print \$2}")
for base in $MQBASE ; do
	if [ -x $base/bin/setmqenv ] ; then
		MQBASE=$base
		break
	fi
done

# Set the MQ environment to the requested environment name
source $MQBASE/bin/setmqenv -p /opt/${env}/mqm
if [ $? -ne 0 ] ; then
  echo "Failed to set MQ environment. Does $env MQ installation exist?"
  exit 1
fi

# Source the common build info
ROOTDIR=`dirname $0`            # get dirname to this script
source ${ROOTDIR}/build_common.bash
initVars MQM create

# -----------------------------------------------------------------------#
# get queue manager list for environment
#
QMLIST=$(dspmq | awk -F "[()]" "/\(${ENV}/ {print \$2}")

# -----------------------------------------------------------------------#
# For each queue manager, check for the overrides file, and 
# run it if found.
# Fail if any issues occur with any file
#
for QMGRNAME in $QMLIST ; do
  # -----------------------------------------------------------------------#
  # Check QUEUE MANAGER is Running
  #
  if [ "$(qmgrStatus)" != "Running" ]; then
    echo "${QMGRNAME} is not running. Abandoning request"
    exit 1
  fi
  
  MQSCFILE=${env}_${QMGRNAME}_overrides.mqsc
  if [ -f ${CONFIGDIR}/${MQSCFILE} ] ; then
    OUTPUT=/tmp/${MQSCFILE}.log
    echo "Applying MQ overrides using  mqsc file..."
    echo "See ${OUTPUT} for detailed runmqsc output"
    doExec "runmqsc ${QMGRNAME} < ${CONFIGDIR}/${MQSCFILE}" > ${OUTPUT}
  fi
done

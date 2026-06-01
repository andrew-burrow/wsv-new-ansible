#!/bin/bash

# QMgr deletion script for MQ v8.
# Finds installation via /etc/opt/mqm/mqinst.ini
# Sets environment using the discovered installation directory
# Deletes service configuration after stopping and deleting the queue manager

MQMUSR="mqm"
QMGR_EXISTS=12

usage()
{
  echo "USAGE: $(basename $0) env props_file"
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

if [ $# -ne 2 ];then
  usage
  exit 1
fi

if [ $(whoami) != "root" ];then
  echo "ERROR: script must be run as root"
  exit 1
fi

# Collect command line arguments
export ENV=$1
export PROPS=$2

# Find the first MQ installation location
MQBASE=$(cat /etc/opt/mqm/mqinst.ini | awk -F "=" "/FilePath/ {print \$2}")
for base in $MQBASE ; do
        if [ -x $base/bin/setmqenv ] ; then
                MQBASE=$base
                break
        fi
done

# Set the MQ environment to the requested environment name
source $MQBASE/bin/setmqenv -p /opt/${ENV}/mqm
if [ $? -ne 0 ] ; then
  echo "Failed to set MQ environment. Does $ENV MQ installation exist?"
  exit 1
fi

# Source the common build info
ROOTDIR=`dirname $0`            # get dirname to this script
source ${ROOTDIR}/build_common.bash
initVars MQM delete

if [ ! -f ${CONFIGDIR}/$PROPS.prop ] ; then
  echo "ERROR: props file not found: $PROPS"
  echo "Locate props file in properties directory, with .prop suffix"
  echo "Available props files are:"
  (cd ${CONFIGDIR}/; ls *.prop | while read a ; do basename $a .prop ; done)
  exit 1
fi
PROPS=${CONFIGDIR}/$PROPS.prop
source $PROPS

# echo QMGR_TEMPLATE=$QMGR_TEMPLATE
# echo QMGRNAME=$QMGRNAME
# echo QMPREFIX=$QMPREFIX
# echo SHORTPREFIX=$SHORTPREFIX
# echo QMHOST+$QMHOST
# echo REPOENV=$REPOENV
# echo REPONUM=$REPONUM
# echo REPOPREFIX=$REPOPREFIX
# echo REPOHOST=$REPOHOST
# echo QMTYPE=$QMTYPE
# echo QMPORT=$QMPORT
# echo REPOPORT=$REPOPORT
# echo CLUSTER=$CLUSTER
# echo ADMINROLE=$ADMINROLE

# -----------------------------------------------------------------------#
# stop QUEUE MANAGER
#
if [ "$(qmgrExists)" == "true" -a "$(qmgrStatus)" == "Running" ] ; then
  doExec "endmqm -i ${QMGRNAME}"
fi

# -----------------------------------------------------------------------#
# delete QUEUE MANAGER
#

if [ "$(qmgrExists)" == "true" ] ; then
  doExec "dltmqm ${QMGRNAME}"
else
  echo "Queue Manager ${QMGRNAME} does not exist. Nothing to do"
  exit 0
fi

# -----------------------------------------------------------------------#
# Remove service from rc?.d
#

echo "Removing auto start/stop service for ${QMGRNAME}"
if [ -h /etc/init.d/mq_${QMGRNAME} ] ; then
  chkconfig --del mq_${QMGRNAME}
fi

# -----------------------------------------------------------------------#
# Remove service from /etc/init.d
#

echo "Removing service mq_${QMGRNAME} for controlling deleted queue manager"
if [ -h /etc/init.d/mq_${QMGRNAME} ]; then
  rm -f /etc/init.d/mq_${QMGRNAME}
fi


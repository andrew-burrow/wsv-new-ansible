#!/bin/bash

# Q deletion script for MQ v8.
# Finds installation via /etc/opt/mqm/mqinst.ini
# Sets environment using the discovered installation directory
# Deletes all non-system queues

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
# Check that the QUEUE MANAGER is running
#
if [ "$(qmgrExists)" == "true" -a "$(qmgrStatus)" == "Running" ] ; then
  :
else
  echo "error: QMgr ${QMGRNAME} not found or not running."
  exit 15
fi

# -----------------------------------------------------------------------#
# discover and delete local queues
#
# Set up file names
OUTPUT=$(dirname ${PROPS})/${ENV}_${QMTYPE}_${PROPNAME}.mqsc
touch ${OUTPUT}
chmod 644 $OUTPUT
DISFILE=$(dirname ${PROPS})/${ENV}_${QMTYPE}_${PROPNAME}.dis
touch ${DISFILE}
chmod 666 $DISFILE
DELFILE=$(dirname ${PROPS})/${ENV}_${QMTYPE}_${PROPNAME}.del
touch ${DELFILE}
chmod 666 $DELFILE

# Generate display request file
cat <<DISQL > $OUTPUT
display ql(*)
end
DISQL

# Get list of queues
doExec "runmqsc ${QMGRNAME} < $OUTPUT >$DISFILE"

# Generate delete statements for non-system queues
cat $DISFILE | grep -v "(SYSTEM\." | awk -F "[()]" "/QUEUE\(/ {print \"DELETE QL('\" \$2 \"') AUTHREC(YES) PURGE\"}" > $DELFILE

# Delete the non-system local queues
doExec "runmqsc ${QMGRNAME} <$DELFILE"

# -----------------------------------------------------------------------#
# discover and delete remote queues
#
# Generate display request file
cat <<DISQR > $OUTPUT
display qr(*)
end
DISQR

# Get list of queues
doExec "runmqsc ${QMGRNAME} < $OUTPUT >$DISFILE"

# Generate delete statements for non-system queues
cat $DISFILE | grep -v "(SYSTEM\." | awk -F "[()]" "/QUEUE\(/ {print \"DELETE QR('\" \$2 \"') AUTHREC(YES)\"}" > $DELFILE

# Delete the non-system remote queues
doExec "runmqsc ${QMGRNAME} <$DELFILE"

# -----------------------------------------------------------------------#
# discover and delete model queues
#
# Generate display request file
cat <<DISQM > $OUTPUT
display qm(*)
end
DISQM

# Get list of queues
doExec "runmqsc ${QMGRNAME} < $OUTPUT >$DISFILE"

# Generate delete statements for non-system queues
cat $DISFILE | grep -v "(SYSTEM\." | awk -F "[()]" "/QUEUE\(/ {print \"DELETE QM('\" \$2 \"') AUTHREC(YES)\"}" > $DELFILE

# Delete the non-system model queues
doExec "runmqsc ${QMGRNAME} <$DELFILE"

# -----------------------------------------------------------------------#
# discover and delete alias queues
#
# Generate display request file
cat <<DISQA > $OUTPUT
display qa(*)
end
DISQA

# Get list of queues
doExec "runmqsc ${QMGRNAME} < $OUTPUT >$DISFILE"

# Generate delete statements for non-system queues
cat $DISFILE | grep -v "(SYSTEM\." | awk -F "[()]" "/QUEUE\(/ {print \"DELETE QA('\" \$2 \"') AUTHREC(YES)\"}" > $DELFILE

# Delete the non-system alias queues
doExec "runmqsc ${QMGRNAME} <$DELFILE"


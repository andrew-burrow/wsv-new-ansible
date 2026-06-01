#!/bin/bash

# MQ application object creation script for MQ v8.
# Based on createMQApp.bash but designed to run as
# mqm instead of root.
# Finds installation via /etc/opt/mqm/mqinst.ini
# Sets environment using the discovered installation directory

MQMUSR="mqm"
QMGR_EXISTS=12

usage()
{
  echo "USAGE: $(basename $0) env app_props_file"
}


doExec()
{
     cmd=$1
     # echo "simulating: $cmd"
     # pwd
     echo "performing: $cmd" >&2
     eval $cmd
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

# if no parameters, check whether there is a command line
# from ssh in the SSH_ORIGINAL_COMMAND variable

# If that exists, take the parameters from there, otherwise
# from the command line.

if [ $# -eq 0 ] ; then
        if [ ! -z "$SSH_ORIGINAL_COMMAND" ] ; then
                declare OrigArgs=($SSH_ORIGINAL_COMMAND)
                OrigCmd=$(basename ${OrigArgs[0]})
                if [ "$OrigCmd" == "applyMQApp.bash" ] ; then
                        export ENV=${OrigArgs[1]}
                        export PROPS=${OrigArgs[2]}
                else
                        echo "Error: Unrecognised command line... $SSH_ORIGINAL_COMMAND"
						exit 2
                fi
        else
                usage
				exit 1
        fi
elif [ $# -eq 2 ];then
        export ENV=$1
        export PROPS=$2
else
		usage
		exit 1
fi

if [ $(whoami) != "mqm" ];then
  echo "ERROR: script must be run as mqm"
  exit 1
fi

# Build PROPNAME field
export PROPNAME=$PROPS

# Find a working MQ installation location
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
source ${ROOTDIR}/../functions.bash
export CONFIGDIR=$ROOTDIR/../../properties

if [ ! -f ${CONFIGDIR}/$PROPS.prop ] ; then
  echo "ERROR: props file not found: $PROPS"
  echo "Locate props file in properties directory, with .prop suffix"
  echo "Available props files are:"
  (cd ${CONFIGDIR}/; ls *.prop | while read a ; do basename $a .prop ; done)
  exit 1
fi
ORIGCONFIGDIR=$CONFIGDIR
export CONFIGDIR=/tmp/$$/config
mkdir -p $CONFIGDIR
cp $ORIGCONFIGDIR/$PROPS.* $CONFIGDIR
PROPS=${CONFIGDIR}/$PROPS.prop
source $PROPS

TEMPLATE=$QMGR_TEMPLATE
if [ -z ${TEMPLATE} ] ; then
  echo "ERROR: variable \$QMGR_TEMPLATE not defined in ${PROPS}"
  exit 1
fi
MAPPING=${TEMPLATE}.map

# -----------------------------------------------------------------------#
# check files
#
for f in $TEMPLATE $PROPS $MAPPING; do
  if [ ! -f $f ]; then
    echo "ERROR: file not found: $f"
    exit 1
  fi
done

# -----------------------------------------------------------------------#
# Check QUEUE MANAGER is Running
#
if [ "$(qmgrStatus)" != "Running" ]; then
  echo "${QMGRNAME} is not running. Abandoning request"
  exit 1
fi

# -----------------------------------------------------------------------#
# create QUEUE MANAGER OBJECTS CONFIGURATION FILE
#
echo "Generating mqsc file from template..."
OUTPUT=${CONFIGDIR}/${ENV}_${QMTYPE}_${PROPNAME}.mqsc
touch ${OUTPUT}
chmod 644 $OUTPUT
cp ${ROOTDIR}/../translate.bash ${CONFIGDIR}
chmod +x ${CONFIGDIR}/translate.bash
${CONFIGDIR}/translate.bash ${TEMPLATE} ${PROPS} ${MAPPING} ${OUTPUT}
if [ $? -ne 0 ] ; then
        echo "Error: translation of template failed. Giving up"
        exit 1
fi

# -----------------------------------------------------------------------#
# create QUEUE MANAGER OBJECTS
#
echo "Creating MQ object using  mqsc file..."
echo "See /tmp/${QMGRNAME}_${PROPNAME}.mqsc.log for detailed runmqsc output"
doExec "runmqsc ${QMGRNAME} < ${OUTPUT}" > /tmp/${QMGRNAME}_${PROPNAME}.mqsc.log

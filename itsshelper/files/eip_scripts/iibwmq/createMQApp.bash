#!/bin/bash
#
# /opt/scripts/createQMGR.bash
#
# -   Create the queues and supporting configuration
#
# -   Derived from script in `itsshelper` repository
#

usage()
{
    echo "USAGE: $(basename $0) ENV APP_PROPS_FILE"
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

# ----------------------------------------------------------------------------
# Check command line argument count
#
if [ $# -ne 2 ]
then
    usage
    exit 1
fi

# ----------------------------------------------------------------------------
# Check for privileged user
#
if [ $(whoami) != "root" ]
then
    echo "ERROR: script must be run as root"
    exit 1
fi

# ----------------------------------------------------------------------------
# Collect command line arguments.  Export ENV for access in `translate.bash`
#
export ENV=$1
LENV=${ENV,,}            # lower case
UENV=${ENV^^}            # upper case
PROPS=$2

# ----------------------------------------------------------------------------
# Find a working MQ installation location
#
MQBASE=$(cat /etc/opt/mqm/mqinst.ini | awk -F "=" "/FilePath/ {print \$2}")
for base in ${MQBASE}
do
    if [ -x $base/bin/setmqenv ]
    then
        MQBASE=$base
        break
    fi
done

# ----------------------------------------------------------------------------
# Set the MQ environment to the requested environment name
#
source ${MQBASE}/bin/setmqenv -p /opt/ibm/${LENV}/mqm
if [ $? -ne 0 ]
then
    echo "Failed to set MQ environment. Does $env MQ installation exist?"
    exit 1
fi

# ----------------------------------------------------------------------------
# Source the common build info
#
ROOTDIR=$(dirname $0)
source ${ROOTDIR}/common_vars.bash

# ----------------------------------------------------------------------------
# Source the PROPS file
#
if [ ! -f ${CONFIGDIR}/$PROPS.prop ]
then
    echo "ERROR: props file not found: $PROPS"
    echo "Locate props file in properties directory, with .prop suffix"
    echo "Available props files are:"
    (cd ${CONFIGDIR}/; ls *.prop | while read a ; do basename $a .prop ; done)
    exit 1
fi
PROPSFILE=${CONFIGDIR}/$PROPS.prop
source $PROPSFILE

# ----------------------------------------------------------------------------
# Determine the template and mapping
#
TEMPLATE=${QMGR_TEMPLATE}
if [ -z ${TEMPLATE} ]
then
    echo "ERROR: variable QMGR_TEMPLATE not defined in ${PROPSFILE}"
    exit 1
fi
MAPPING=${TEMPLATE}.map

# ----------------------------------------------------------------------------
# Check existence of files required for templating
#
for f in $TEMPLATE $PROPS $MAPPING
do
    if [ ! -f $f ]
    then
        echo "ERROR: file not found: $f"
        exit 1
    fi
done

# ----------------------------------------------------------------------------
# Check QUEUE MANAGER is Running
#
if [ "$(qmgrStatus)" != "Running" ]
then
    echo "${QMGRNAME} is not running. Abandoning request"
    exit 1
fi

# ----------------------------------------------------------------------------
# Create QUEUE MANAGER OBJECTS CONFIGURATION FILE
#
echo "Generating mqsc file from template..."
OUTPUT=$(dirname ${PROPSFILE})/${LENV}_${QMTYPE}_${PROPS}.mqsc
touch ${OUTPUT}
chmod 644 $OUTPUT
${ROOTDIR}/translate.bash ${TEMPLATE} ${PROPSFILE} ${MAPPING} ${OUTPUT}
if [ $? -ne 0 ]
then
        echo "Error: translation of template failed. Giving up"
        exit 1
fi

# ----------------------------------------------------------------------------
# Create QUEUE MANAGER OBJECTS
#
echo "Creating MQ object using  mqsc file..."
echo "See /tmp/${QMGRNAME}_${PROPS}.mqsc.log for detailed runmqsc output"
doExec "runmqsc ${QMGRNAME} < ${OUTPUT}" > /tmp/${QMGRNAME}_${PROPS}.mqsc.log

# ----------------------------------------------------------------------------
# Mark completion
#
echo "Queue creation for ${PROPS} completed."

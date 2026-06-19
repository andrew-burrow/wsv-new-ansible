#!/bin/bash
#
# /opt/scripts/createQMGR.bash
#
# -   Create a queue manager
#
# -   Derived from script in `itsshelper` repository
#
# -   Note that `translate.bash` runs in its own process, so it can only
#     access variables defined in the PROPSFILE, OR explicity exported
#

usage()
{
    echo "USAGE: $(basename $0) ENV PROPS_FILE"
}

doExec()
{
    cmd=$1
    echo "performing: $cmd" >&2
    su ${MQMUSR} -c "$cmd"
    if [ $? -ne 0 ]; then
        echo "ERROR executing command: ${cmd}" >&2
        echo "Exiting script..." >&2
        exit 1
    fi
}

qmgrExists()
{
    dspmq -m "${QMGRNAME}" > /dev/null 2>&1
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
echo CONFIGDIR=${CONFIGDIR}
if [ ! -f ${CONFIGDIR}/${PROPS}.prop ]
then
    echo "ERROR: props file not found: ${PROPS}"
    echo "Locate props file in properties directory, with .prop suffix"
    echo "Available props files are:"
    (cd ${CONFIGDIR}/; ls *.prop | while read a ; do basename $a .prop ; done)
    exit 1
fi
PROPSFILE=${CONFIGDIR}/${PROPS}.prop
source ${PROPSFILE}

# ----------------------------------------------------------------------------
# Validate the repository queue manager
#
# It must not be blank
# It must not be the current (new) queue manager
# It must share the same 3 character environment string
# The fifth character must be F
#
if [ -z "${REPOQM}" ]
then
    echo "Invalid mqrepo.prop. No repository defined for ${QMGRNAME}"
    exit 1
fi
if [ "${QMGRNAME}" == "${REPOQM}" ]
then
    echo "Invalid mqrepo.prop. ${REPOQM} cannot be the created qmgr ${QMGRNAME}"
    exit 1
fi
if [ "${QMGRNAME:1:3}" != "${REPOQM:0:3}" ]
then
    echo "Invalid Repository QM name ${REPOQM} defined in mqrepo.prop"
    echo "It must be in the same environment as the new QM"
    exit 1
fi
if [ "${REPOQM:4:1}" != "F" ]
then
    echo "Invalid Repository QM name ${REPOQM} defined in mqrepo.prop"
    echo "Not a full repository style name"
    exit 1
fi

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
for f in ${TEMPLATE} ${PROPSFILE} ${MAPPING} ${REPOLIST}
do
    if [ ! -f $f ]
    then
        echo "ERROR: file not found: $f"
        exit 1
    fi
done

# ----------------------------------------------------------------------------
# Check host name resolution
#
getent hosts ${QMHOST} > /dev/null
if [ $? -ne 0 ]
then
    echo "Could not resolve QMHOST ${QMHOST}"
    exit 1
fi
getent hosts ${REPOHOST} > /dev/null
if [ $? -ne 0 ]
then
    echo "Could not resolve REPOHOST ${REPOHOST}"
    exit 1
fi

# ----------------------------------------------------------------------------
# Create QUEUE MANAGER
#
if [ $(qmgrExists) == "false"  ]
then
    doExec "crtmqm -c \"${QMTYPE} QMgr for $env environment\" -lc -lf 4096 -lp 10 -ls 4 -u SYSTEM.DEAD.LETTER.QUEUE ${QMGRNAME}"
else
    echo "${QMGRNAME} already exists..."
fi

# ----------------------------------------------------------------------------
# Set queue manager to command level 930 to enable LDAP
#
if [ "$(qmgrStatus)" != "Running" ]
then
  #doExec "strmqm -e CMDLEVEL=930 ${QMGRNAME}"
  doExec "strmqm ${QMGRNAME}"
fi

# ----------------------------------------------------------------------------
# Find QM directory. Get prefix and dirname from dspmqinf
#
QMGR_PREFIX_DIR=$(doExec "dspmqinf -o stanza ${QMGRNAME}" | awk -F "=" "/Prefix/ {print \$2}")
QMGR_DIRNAME=$(doExec "dspmqinf -o stanza ${QMGRNAME}" | awk -F "=" "/Directory/ {print \$2}")
QMGR_DIR=${QMGR_PREFIX_DIR}/qmgrs/${QMGR_DIRNAME}

# ----------------------------------------------------------------------------
# Set Security Policy mode to user (default is group)
#

# Use awk to add the SecurityPolicy line to the AuthorizationService stanza
cat ${QMGR_DIR}/qm.ini | awk "BEGIN {doit=0};/Name=AuthorizationService/ {doit=1};/SecurityPolicy/ {doit=0};/^ServiceComponent:/ {if (doit==1) {print \"   SecurityPolicy=user\";doit=0}}; {print}" > ${QMGR_DIR}/qm.ini.temp
if [ $? -eq 0 ]
then
    mv ${QMGR_DIR}/qm.ini.temp ${QMGR_DIR}/qm.ini
    chown ${MQMUSR}:${MQMUSR} ${QMGR_DIR}/qm.ini
else
    rm -f ${QMGR_DIR}/qm.ini.temp
fi

# ----------------------------------------------------------------------------
# Set Channels stanza if it doesn't already exist
#
grep -E -q "^Channels:" ${QMGR_DIR}/qm.ini
if [ $? -eq 0 ]
then
    echo "Channels stanza already exists."
    echo "Adjust if necessary"
else
    cat <<'CHANNELS.INI' >> ${QMGR_DIR}/qm.ini
Channels:
   MaxChannels=1000
   MaxActiveChannels=1000
   AdoptNewMCA=ALL
   AdoptNewMCATimeout=60
   AdoptNewMCACheck=QM,NAME
CHANNELS.INI
    echo "Channels stanza set for ${QMGRNAME}"
fi

# ----------------------------------------------------------------------------
# Set Security stanza if it doesn't already exist
#
grep -E -q "^Security:" ${QMGR_DIR}/qm.ini
if [ $? -eq 0 ]
then
    echo "Security stanza already exists."
    echo "Adjust if necessary"
else
    cat <<'SECURITY.INI' >> ${QMGR_DIR}/qm.ini
Security:
   ClusterQueueAccessControl=RQMName
SECURITY.INI
    echo "Security stanza set for ${QMGRNAME}"
fi

# ----------------------------------------------------------------------------
# Set SSL stanza if it doesn't already exist
#
grep -E -q "^SSL:" ${QMGR_DIR}/qm.ini
if [ $? -eq 0 ]
then
    echo "SSL stanza already exists."
    echo "Adjust if necessary"
else
    cat <<'SSL.INI' >> ${QMGR_DIR}/qm.ini
SSL:
   CDPCheckExtensions=NO
   OCSPCheckExtensions=NO
   OCSPAuthentication=OPTIONAL
SSL.INI
    echo "Security stanza set for ${QMGRNAME}"
fi

# Start QUEUE MANAGER
#
if [ "$(qmgrStatus)" != "Running" ]
then
    doExec "strmqm ${QMGRNAME}"
else
    echo "${QMGRNAME} already started..."
fi

# ----------------------------------------------------------------------------
# Create QUEUE MANAGER OBJECTS CONFIGURATION FILE
#
echo "Generating mqsc file from template..."
OUTPUT=$(dirname ${PROPSFILE})/${LENV}_${QMTYPE}.mqsc
touch ${OUTPUT}
chmod 644 ${OUTPUT}
${ROOTDIR}/translate.bash ${TEMPLATE} ${PROPSFILE} ${MAPPING} ${OUTPUT}
if [ $? -ne 0 ]
then
    echo "Error: Translation of template failed. Giving up"
    exit 1
fi

# ----------------------------------------------------------------------------
# Create QUEUE MANAGER OBJECTS
#
echo "Creating MQ object using  mqsc file..."
echo "See /tmp/${QMGRNAME}.mqsc.log for detailed runmqsc output"
doExec "runmqsc ${QMGRNAME} < ${OUTPUT}" > /tmp/${QMGRNAME}.mqsc.log

# ----------------------------------------------------------------------------
# Mark completion
#
echo "Queue Manager creation for ${QMGRNAME} completed."

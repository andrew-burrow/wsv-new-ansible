#!/bin/bash

ENV=$1
SP_PROPS=$2
# env is the environment name forced to lower case
env=${ENV,,}
# ENV is the environment name forced to upper case in case we need it
ENV=${env^^}
IIB_ADMIN_USER=iibadmin

ROOTDIR=$(dirname $0)
MQSI_ROOT=/opt/${env}/iib/server
MQSI_BIN_LOC=${MQSI_ROOT}/bin

usage()
{
  echo "USAGE: $(basename $0) environment sp_app_props_file"
}

error()
{
  echo "ERROR: #1"
  echo "Exiting script..."
  exit 1
}

executeCommand()
{
  cmd=$1
  taskMsg=$2
  
  echo "Performing: $taskMsg"
  echo "Executing: $cmd"
  su $IIB_ADMIN_USER -c "$cmd"
  if [ $? -ne 0 ]; then
    echo "ERROR: $taskMsg"
    echo "Exiting script..."
    exit 1
  fi
}

deleteSecurityProfile()
{
  PROFILE_NM=$1
  echo "==========================================================="
  echo "Checking Security Profile: ${PROFILE_NM}"
  su $IIB_ADMIN_USER -c "${MQSI_BIN_LOC}/mqsireportproperties ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o ${PROFILE_NM} -a"
  if [ $? -ne 0 ]; then
    echo "Security Profile ${PROFILE_NM} does NOT exist."
  else
    executeCommand "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o ${PROFILE_NM}" "Delete Security Profile: ${PROFILE_NM}"
  fi
}

# -----------------------------------------------------------------------#
# root must run this scirpt
#
if [ $(whoami) != "root" ];then
  echo "ERROR: script MUST run as root"
  exit 1
fi

# -----------------------------------------------------------------------#
# check usage
#
if [ $# -ne 2 ] ; then
  usage
  exit 1
fi

# Initialise
source ${ROOTDIR}/build_common.bash
initVars IIB create

# -----------------------------------------------------------------------#
# load property file
#
PROPS=${CONFIGDIR}/IIB_${env}_config.properties
if [ ! -f $PROPS ] ; then
  echo "ERROR: props file not found: $PROPS"
  exit 1
fi

source ${PROPS}

# -----------------------------------------------------------------------#
# TODO:CHECK env set
#

source /opt/${env}/iib/server/bin/mqsiprofile

# -----------------------------------------------------------------------#
# load app specific Security Profile property file
#
if [ ! -f ${CONFIGDIR}/$SP_PROPS.prop ] ; then
  echo "ERROR: security profile props file not found: $SP_PROPS"
  exit 1
fi
SP_PROPS=${CONFIGDIR}/$SP_PROPS.prop

source ${SP_PROPS}


# -----------------------------------------------------------------------#
# Delete Provider Policy for the app
#

for (( i=0 ; i<${#SECURITY_PROFILE_PROVIDER[*]} ; i++ )) ; do
  deleteSecurityProfile ${SECURITY_PROFILE_PROVIDER[i]}
done

# -----------------------------------------------------------------------#
# Delete Consumer Policy for the app
#

for (( i=0 ; i<${#SECURITY_PROFILE_CONSUMER[*]} ; i++ )) ; do
  deleteSecurityProfile ${SECURITY_PROFILE_CONSUMER[i]}
done

echo "==========================================================="
echo "Security Profile deletion completed successfully"

#!/bin/bash

ENV=$1
WLM_PROPS=$2
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
  echo "USAGE: $(basename $0) environment wlm_app_props_file"
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

deleteWLMPolicy()
{
  POLICY_NM=$1
  
  echo "==========================================================="
  echo "Checking WLM Policy: ${POLICY_NM}"
  su $IIB_ADMIN_USER -c "${MQSI_BIN_LOC}/mqsireportpolicy ${INTEGRATION_NODE_NAME} -t WorkloadManagement -l ${POLICY_NM}"
  if [ $? -eq 0 ]; then
    echo "WLM Policy ${POLICY_NM} exist."
    executeCommand "${MQSI_BIN_LOC}/mqsideletepolicy ${INTEGRATION_NODE_NAME} -t WorkloadManagement -l ${POLICY_NM}" "Delete WLM Policy: ${POLICY_NM}"
  else
    echo "WLM Policy ${POLICY_NM} does NOT exist."
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
#

source /opt/${env}/iib/server/bin/mqsiprofile



# -----------------------------------------------------------------------#
# load wlm property file
#
if [ ! -f ${CONFIGDIR}/$WLM_PROPS.prop ] ; then
  echo "ERROR: wlm props file not found: $WLM_PROPS"
  exit 1
fi
WLM_PROPS=${CONFIGDIR}/$WLM_PROPS.prop

source ${WLM_PROPS}


# -----------------------------------------------------------------------#
# Delete WLM Policy for all Modules
#

for (( i=0 ; i<${#WLM_POLICIES[*]} ; i++ )) ; do
  deleteWLMPolicy ${WLM_POLICIES[i]%%:*}
done


echo "==========================================================="
echo "WLM Policy deletion completed successfully"

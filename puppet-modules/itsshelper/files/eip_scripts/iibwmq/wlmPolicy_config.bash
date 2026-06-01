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

createWLMPolicy()
{
  POLICY_NM=$1
  ADDITIONAL_INSTANCES=$2
  
  echo "==========================================================="
  echo "Checking WLM Policy: ${POLICY_NM}"
  createPolicyDocument
  su $IIB_ADMIN_USER -c "${MQSI_BIN_LOC}/mqsireportpolicy ${INTEGRATION_NODE_NAME} -t WorkloadManagement -l ${POLICY_NM}"
  if [ $? -ne 0 ]; then
    echo "WLM Policy ${POLICY_NM} does NOT exist."
    executeCommand "${MQSI_BIN_LOC}/mqsicreatepolicy ${INTEGRATION_NODE_NAME} -t WorkloadManagement -l ${POLICY_NM} -f \"${WLM_POLICY_FILE}\"" "Create WLM Policy: ${POLICY_NM}"
  else
    echo "WLM Policy ${POLICY_NM} exist, updating the policy."
    executeCommand "${MQSI_BIN_LOC}/mqsichangepolicy ${INTEGRATION_NODE_NAME} -t WorkloadManagement -l ${POLICY_NM} -f \"${WLM_POLICY_FILE}\"" "Update WLM Policy: ${POLICY_NM}"
  fi
}

createPolicyDocument()
{
  WLM_POLICY_FILE=/tmp/${POLICY_NM}-${ADDITIONAL_INSTANCES}.xml
  
  cp -f ${CONFIGDIR}/WLMPolicy.xml ${WLM_POLICY_FILE}
  sed -i -e "s/__ADDITIONAL_INSTANCES__/${ADDITIONAL_INSTANCES}/g" $WLM_POLICY_FILE
  
  echo "Created WLM Policy file ${WLM_POLICY_FILE}."
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
# load common property file
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
# load wlm property file
#
if [ ! -f ${CONFIGDIR}/$WLM_PROPS.prop ] ; then
  echo "ERROR: wlm props file not found: $WLM_PROPS"
  exit 1
fi
WLM_PROPS=${CONFIGDIR}/$WLM_PROPS.prop

source ${WLM_PROPS}


# -----------------------------------------------------------------------#
# Create WLM Policy for the app
#

for (( i=0 ; i<${#WLM_POLICIES[*]} ; i++ )) ; do
  createWLMPolicy ${WLM_POLICIES[i]%%:*} ${WLM_POLICIES[i]##*:}
done


echo "==========================================================="
echo "WLM Policy creation completed successfully"

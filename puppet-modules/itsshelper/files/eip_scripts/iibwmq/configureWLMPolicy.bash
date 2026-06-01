#!/bin/bash

ENV=$1
BRK_ID=$2
WLM_PROPS=$3

# env is the environment name forced to lower case
env=${ENV,,}
# ENV is the environment name forced to upper case in case we need it
ENV=${env^^}
# brk_id is the BrokerIdentifier name forced to lower case
brk_id=${BRK_ID,,}

IIB_ADMIN_USER=iibadmin

ROOTDIR=$(dirname $0)
MQSI_ROOT=/opt/${env}/iib/server
MQSI_BIN_LOC=${MQSI_ROOT}/bin

usage()
{
  echo "USAGE: $(basename $0) environment brokerIdentifier wlm_app_props_file"
  echo "where"
  echo "	environment is a 3-or-less-character label denoting an environment"
  echo "	brokerIdentifier is one the following options DEFAULT | RAD | JUMBO"
  echo "	wlm_app_props_file is WLM Ploicy app name"
}

doMqsiExec()
{
  cmd=$1

  echo "==========================================================="
  echo "performing: su $IIB_ADMIN_USER -c $cmd"
  su $IIB_ADMIN_USER -c "$cmd"
  if [ $? -ne 0 ]; then
    echo "ERROR executing command: ${cmd}"
    echo "Exiting script..."
    exit 1
  fi
}

deleteWLMPolicy()
{
  POLICY_NM=$1
  
  echo "==========================================================="
  echo "Checking WLM Policy: ${POLICY_NM}"
  su $IIB_ADMIN_USER -c "${MQSI_BIN_LOC}/mqsireportpolicy ${INTEGRATION_NODE_NAME} -t WorkloadManagement -l ${POLICY_NM}  > /dev/null 2>&1"
  if [ $? -eq 0 ]; then
    doMqsiExec "${MQSI_BIN_LOC}/mqsideletepolicy ${INTEGRATION_NODE_NAME} -l ${POLICY_NM} -t WorkloadManagement"
  fi
}

createWLMPolicy()
{
  POLICY_NM=$1
  ADDITIONAL_INSTANCES=$2
  
  echo "==========================================================="
  echo "Checking WLM Policy: ${POLICY_NM}  Additional Instances: ${ADDITIONAL_INSTANCES}"
  createPolicyDocument
  su $IIB_ADMIN_USER -c "${MQSI_BIN_LOC}/mqsireportpolicy ${INTEGRATION_NODE_NAME} -t WorkloadManagement -l ${POLICY_NM}  > /dev/null 2>&1"
  if [ $? -ne 0 ]; then
    echo "WLM Policy ${POLICY_NM} does NOT exist, creating the policy."
    doMqsiExec "${MQSI_BIN_LOC}/mqsicreatepolicy ${INTEGRATION_NODE_NAME} -t WorkloadManagement -l ${POLICY_NM} -f \"${WLM_POLICY_FILE}\""
  else
    echo "WLM Policy ${POLICY_NM} exist, updating the policy."
    doMqsiExec "${MQSI_BIN_LOC}/mqsichangepolicy ${INTEGRATION_NODE_NAME} -t WorkloadManagement -l ${POLICY_NM} -f \"${WLM_POLICY_FILE}\""
  fi
  
  rm -f ${WLM_POLICY_FILE}
}

createPolicyDocument()
{
  WLM_POLICY_FILE=/tmp/${POLICY_NM}-${ADDITIONAL_INSTANCES}.xml
  
  # Remove the temporary policy file if it already exists
  if [[ -f ${WLM_POLICY_FILE} ]]; then
    rm -f ${WLM_POLICY_FILE}
  fi

  cp -f ${CONFIGDIR}/WLMPolicy.xml ${WLM_POLICY_FILE}
  chown iibadmin:mqbrkrs ${WLM_POLICY_FILE}

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
if [ $# -ne 3 ] ; then
  usage
  exit 1
fi

# -----------------------------------------------------------------------#
# check broker Identifier
#
if [ "$brk_id" != 'default' ] && [ "$brk_id" != 'rad' ] && [ "$brk_id" != 'jumbo' ] ; then
  usage
  exit 1
fi

# -----------------------------------------------------------------------#
# Initialise
source ${ROOTDIR}/build_common.bash
initVars IIB create

# -----------------------------------------------------------------------#
# load property file
#
PROPS=${CONFIGDIR}/IntegrationNodeConfig-${brk_id}-${env}.properties
if [ ! -f $PROPS ] ; then
  echo "ERROR: props file not found: $PROPS"
  exit 1
fi

source ${PROPS}


# -----------------------------------------------------------------------#
# Enable access to broker commands (mqsi)
#
source /opt/${env}/iib/server/bin/mqsiprofile


# -----------------------------------------------------------------------#
# load app specific WLM Policy property file
#
if [ ! -f ${CONFIGDIR}/${WLM_PROPS}.prop ] ; then
  echo "ERROR: WLM Policy props file not found: ${WLM_PROPS}.prop"
  exit 1
fi
source ${CONFIGDIR}/${WLM_PROPS}.prop


# -----------------------------------------------------------------------#
# Delete WLM Policy
#
for DELETE_WLM in ${DELETE_WLM_LIST[*]} ; do
  deleteWLMPolicy ${DELETE_WLM}
done

# -----------------------------------------------------------------------#
# Create WLM Policy for the app
#
for WLM in ${WLM_LIST[*]} ; do
  createWLMPolicy ${WLM_POLICY_NAME[${WLM}]} ${ADDITIONAL_INSTANCES[${WLM}]}
done

echo "==========================================================="
echo "WLM Policy creation completed successfully"

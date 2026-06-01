#!/bin/bash

ENV=$1
BRK_ID=$2
SP_PROPS=$3

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

RED='\x1b[31m'
GREEN='\x1b[32m'
YELLOW='\x1b[33m'
RESET='\x1b[0m'

usage()
{
  echo "USAGE: $(basename $0) environment brokerIdentifier sp_app_props_file"
  echo "where"
  echo "	environment is a 3-or-less-character label denoting an environment"
  echo "	brokerIdentifier is one the following options DEFAULT | RAD | JUMBO"
  echo "	sp_app_props_file is security profile app name"
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

deleteProviderSecurityProfile()
{
  PROFILE_NM=$1
  echo "==========================================================="
  echo "Checking Security Profile: ${PROFILE_NM}"
  su $IIB_ADMIN_USER -c "${MQSI_BIN_LOC}/mqsireportproperties ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o ${PROFILE_NM} -a > /dev/null 2>&1"
  if [ $? -eq 0 ]; then
    doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o ${PROFILE_NM}"
  fi
}

createProviderSecurityProfile()
{
  PROFILE_NM=$1
  echo "==========================================================="
  echo "Checking Security Profile: ${PROFILE_NM}"
  su $IIB_ADMIN_USER -c "${MQSI_BIN_LOC}/mqsireportproperties ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o ${PROFILE_NM} -a > /dev/null 2>&1"
  if [ $? -ne 0 ]; then
    doMqsiExec "${MQSI_BIN_LOC}/mqsicreateconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o ${PROFILE_NM} -n authentication,authenticationConfig,authorization,authorizationConfig,propagation,rejectBlankpassword,passwordValue -v \"LDAP\",\\\"ldaps://${LDAP_HOST}:${LDAP_PORT}/o=vwa?cn\\\",LDAP,\\\"ldaps://${LDAP_HOST}:${LDAP_PORT}/cn=ROL-EIPCORE-${PROFILE_NM}-${ENV},ou=GROUPS,o=vwa\\\",TRUE,FALSE,MASK"
  else
    echo "Security Profile ${PROFILE_NM} exist."
  fi
}

deleteConsumerSecurityProfile()
{
  PROFILE_NM=$1
  echo "==========================================================="
  echo "Checking Security Profile: ${PROFILE_NM}"
  su $IIB_ADMIN_USER -c "${MQSI_BIN_LOC}/mqsireportproperties ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o ${PROFILE_NM} -a > /dev/null 2>&1"
  if [ $? -eq 0 ]; then
    doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o ${PROFILE_NM}"
    doMqsiExec "${MQSI_BIN_LOC}/mqsisetdbparms ${INTEGRATION_NODE_NAME} -n ${PROFILE_NM}_WSSecurityId -d"
  fi
}

createConsumerSecurityProfile()
{
  PROFILE_NM=$1
  SP_USER_ID=$2
  SP_USER_PWD=$3
  
  echo "==========================================================="
  echo "Checking Security Profile: ${PROFILE_NM}"
  su $IIB_ADMIN_USER -c "${MQSI_BIN_LOC}/mqsireportproperties ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o ${PROFILE_NM} -a > /dev/null 2>&1"
  if [ $? -ne 0 ]; then
    doMqsiExec "${MQSI_BIN_LOC}/mqsicreateconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o ${PROFILE_NM} -n \"propagation,idToPropagateToTransport,transportPropagationConfig\" -v \"TRUE,STATIC ID,${PROFILE_NM}_WSSecurityId\""
  else
    echo "Security Profile ${PROFILE_NM} exist."
  fi
  
  doMqsiExec "${MQSI_BIN_LOC}/mqsisetdbparms ${INTEGRATION_NODE_NAME} -n ${PROFILE_NM}_WSSecurityId -u ${SP_USER_ID} -p $(decryptPwd ${SP_USER_PWD})"
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
# load app specific Security Profile property file
#
if [ ! -f ${CONFIGDIR}/${SP_PROPS}.prop ] ; then
  echo "ERROR: security profile props file not found: ${SP_PROPS}.prop"
  exit 1
fi
source ${CONFIGDIR}/${SP_PROPS}.prop


# -----------------------------------------------------------------------#
# Delete Provider Policy for the app
#
for DELETE_SECURITY_PROFILE_PROVIDER in ${DELETE_SECURITY_PROFILE_PROVIDER_LIST[*]} ; do
  deleteProviderSecurityProfile ${DELETE_SECURITY_PROFILE_PROVIDER}
done

# -----------------------------------------------------------------------#
# Delete Consumer Policy for the app
#
for DELETE_SECURITY_PROFILE_CONSUMER in ${DELETE_SECURITY_PROFILE_CONSUMER_LIST[*]} ; do
  deleteConsumerSecurityProfile ${DELETE_SECURITY_PROFILE_CONSUMER}
done

# -----------------------------------------------------------------------#
# Create Provider Policy for the app
#
for SECURITY_PROFILE_PROVIDER in ${SECURITY_PROFILE_PROVIDER_LIST[*]} ; do
  createProviderSecurityProfile ${SECURITY_PROFILE_PROVIDER}
done

# -----------------------------------------------------------------------#
# Create Consumer Policy for the app
#
for SECURITY_PROFILE_CONSUMER in ${SECURITY_PROFILE_CONSUMER_LIST[*]} ; do
  createConsumerSecurityProfile ${SECURITY_PROFILE_CONSUMER} ${SP_CONSUMER_USER[${SECURITY_PROFILE_CONSUMER}]} ${SP_CONSUMER_USER_PWD[${SECURITY_PROFILE_CONSUMER}]}
done

echo "==========================================================="
echo "Security Profile creation completed successfully"

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

createConsumerPolicySet()
{
  echo "==========================================================="
  echo "Checking Consumer Policy Set"
  su $IIB_ADMIN_USER -c "${MQSI_BIN_LOC}/mqsireportproperties ${INTEGRATION_NODE_NAME} -c PolicySets -o WSConsumerDefault -a"
  if [ $? -ne 0 ]; then
    echo "Consumer Policy Set does not exist, creating Consumer Policy Set."
    executeCommand "${MQSI_BIN_LOC}/mqsicreateconfigurableservice ${INTEGRATION_NODE_NAME} -c PolicySets -o WSConsumerDefault" "Create Consumer Policy Set"
    executeCommand "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -c PolicySets -o WSConsumerDefault -n ws-security -p \"${CONFIGDIR}/WSConsumerPolicySet.xml\"" "Update Consumer Policy Set"
  else
    echo "Consumer Policy Set exist."
  fi

  echo "==========================================================="
  echo "Checking Consumer Policy Set Binding"
  su $IIB_ADMIN_USER -c "${MQSI_BIN_LOC}/mqsireportproperties ${INTEGRATION_NODE_NAME} -c PolicySetBindings -o WSConsumerDefault -a"
  if [ $? -ne 0 ]; then
    echo "Consumer Policy Set Binding does not exist, creating Consumer Policy Set Binding."
    executeCommand "${MQSI_BIN_LOC}/mqsicreateconfigurableservice ${INTEGRATION_NODE_NAME} -c PolicySetBindings -o WSConsumerDefault" "Create Consumer Policy Set Binding"
    executeCommand "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -c PolicySetBindings -o WSConsumerDefault -n ws-security -p \"${CONFIGDIR}/WSConsumerPolicySetBinding.xml\"" "Update Consumer Policy Set Binding"
    executeCommand "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -c PolicySetBindings -o WSConsumerDefault -n associatedPolicySet -v WSConsumerDefault" "Link Consumer Policy Set"
  else
    echo "Consumer Policy Set Bindings exist."
  fi
}

createProviderSecurityProfile()
{
  PROFILE_NM=$1
  echo "==========================================================="
  echo "Checking Security Profile: ${PROFILE_NM}"
  su $IIB_ADMIN_USER -c "${MQSI_BIN_LOC}/mqsireportproperties ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o ${PROFILE_NM} -a"
  if [ $? -ne 0 ]; then
    echo "Security Profile ${PROFILE_NM} does NOT exist."
    executeCommand "${MQSI_BIN_LOC}/mqsicreateconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o ${PROFILE_NM} -n authentication,authenticationConfig,authorization,authorizationConfig,propagation,rejectBlankpassword,passwordValue -v \"LDAP\",\\\"ldaps://${LDAP_HOST}:${LDAP_PORT}/o=vwa?cn\\\",LDAP,\\\"ldaps://${LDAP_HOST}:${LDAP_PORT}/cn=ROL-EIPCORE-${PROFILE_NM}-${env^^},ou=GROUPS,o=vwa\\\",TRUE,FALSE,MASK" "Create Security Profile: ${PROFILE_NM}"
  else
    echo "Security Profile ${PROFILE_NM} exist."
  fi
}


createConsumerSecurityProfile()
{
  PROFILE_NM=$1
  echo "==========================================================="
  echo "Checking Security Profile: ${PROFILE_NM}"
  su $IIB_ADMIN_USER -c "${MQSI_BIN_LOC}/mqsireportproperties ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o ${PROFILE_NM} -a"
  if [ $? -ne 0 ]; then
    echo "Security Profile ${PROFILE_NM} does NOT exist."
    executeCommand "${MQSI_BIN_LOC}/mqsicreateconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o ${PROFILE_NM} -n \"propagation,idToPropagateToTransport,transportPropagationConfig\" -v \"TRUE,STATIC ID,${PROFILE_NM}_WSSecurityId\"" "Create Security Profile: ${PROFILE_NM}"
  else
    echo "Security Profile ${PROFILE_NM} exist."
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
# TODO: Review if these are required.
#
#Adding the LDAP trust to broker registry
#executeCommand "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -o BrokerRegistry -n brokerTruststoreFile -v \"${CONFIGDIR}/brokerTrustStore.jks\"" "Provide Trust Store location"

# Set the broker with ldap binding user and password
#doMqsiExec "${MQSI_BIN_LOC}/mqsisetdbparms ${INTEGRATION_NODE_NAME} -n ldap::${LDAP_HOST} -u ${LDAP_IIB_BIND_USER} -p ${LDAP_IIB_BIND_PASSWORD}"

# Set the broker trust store password
#executeCommand "${MQSI_BIN_LOC}/mqsisetdbparms ${INTEGRATION_NODE_NAME} -n brokerTruststore::password -u ignore -p ******" "Set Trust Store password"


# -----------------------------------------------------------------------#
# Create Provider Policy for the app
#

for (( i=0 ; i<${#SECURITY_PROFILE_PROVIDER[*]} ; i++ )) ; do
  createProviderSecurityProfile ${SECURITY_PROFILE_PROVIDER[i]}
done

# -----------------------------------------------------------------------#
# Create Consumer Policy for the app
#

createConsumerPolicySet

for (( i=0 ; i<${#SECURITY_PROFILE_CONSUMER[*]} ; i++ )) ; do
  createConsumerSecurityProfile ${SECURITY_PROFILE_CONSUMER[i]}
done

echo "==========================================================="
echo "Security Profile creation completed successfully"

#!/bin/bash

MQ_ADMIN_USER=mqm
ENV=$1
# env is the environment name forced to lower case
env=${ENV,,}
# ENV is the environment name forced to upper case in case we need it
ENV=${env^^}
IIB_ADMIN_USER=iibadmin
QMGR_EXISTS=12

ROOTDIR=$(dirname $0)
MQSI_ROOT=/opt/${env}/iib/server
MQSI_BIN_LOC=${MQSI_ROOT}/bin

ROLE_SUFFIX=-${env^^}

usage()
{
  echo "USAGE: $(basename $0) environment"
  echo "where"
  echo "	environment is a 3-or-less-character label denoting an environment"
}

doMqmExec()
{
     cmd=$1
     
     echo "==========================================================="
     echo "performing: $cmd"
     su $MQ_ADMIN_USER -c "$cmd"
     MQ_RET_VAL=$?
     if [ $MQ_RET_VAL -eq 20 ]; then
       echo "ERROR executing command: ${cmd}"
       echo "Return code: ${MQ_RET_VAL}"
       echo "Exiting script..."
       exit 1
     fi
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
if [ $# -ne 1 ] ; then
  usage
  exit 1
fi

# Initialise
source ${ROOTDIR}/build_common.bash
initVars IIB create

# -----------------------------------------------------------------------#
# load property file
#
PROPS=${CONFIGDIR}/IIBJumbo_${env}_config.properties
if [ ! -f $PROPS ] ; then
  echo "ERROR: props file not found: $PROPS"
  exit 1
fi

source ${PROPS}

# Enable access to MQ 
source /opt/${env}/mqm/bin/setmqenv -s

# -----------------------------------------------------------------------#
# TODO:CHECK env set
#

source /opt/${env}/iib/server/bin/mqsiprofile

#Adding the LDAP trust to broker registry
doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -o BrokerRegistry -n brokerTruststoreFile -v \"${CONFIGDIR}/brokerTrustStore.jks\""

# Set the broker with ldap binding user and password
#doMqsiExec "${MQSI_BIN_LOC}/mqsisetdbparms ${INTEGRATION_NODE_NAME} -n ldap::${LDAP_HOST} -u ${LDAP_IIB_BIND_USER} -p ${LDAP_IIB_BIND_PASSWORD}"

# Set the broker trust store password
doMqsiExec "${MQSI_BIN_LOC}/mqsisetdbparms ${INTEGRATION_NODE_NAME} -n brokerTruststore::password -u ignore -p passw0rd"

# -----------------------------------------------------------------------#
# Create security profiles for all the necessary ROLES 
#

# Reset the Role Suffix in case of prod
# 
if [ ${env} = 'pr1' ] ; then
  ROLE_SUFFIX=''
fi

#doMqsiExec "${MQSI_BIN_LOC}/mqsicreateconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o WORKPLACE -n authentication,authenticationConfig,authorization,authorizationConfig,propagation,rejectBlankpassword,passwordValue -v \"LDAP\",\\\"ldaps://${LDAP_HOST}:${LDAP_PORT}/o=vwa?cn\\\",LDAP,\\\"ldaps://${LDAP_HOST}:${LDAP_PORT}/cn=ROL-EIPCORE-WORKPLACE${ROLE_SUFFIX},ou=GROUPS,o=vwa\\\",TRUE,FALSE,MASK"

echo "restart integration node"
doMqsiExec "${MQSI_BIN_LOC}/mqsistop ${INTEGRATION_NODE_NAME}"
doMqsiExec "${MQSI_BIN_LOC}/mqsistart ${INTEGRATION_NODE_NAME}"

echo "==========================================================="
echo "Security configurableservice completed successfully"

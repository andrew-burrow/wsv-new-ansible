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
PROPS=${CONFIGDIR}/IIB_${env}_config.properties
if [ ! -f $PROPS ] ; then
  echo "ERROR: props file not found: $PROPS"
  exit 1
fi

source ${PROPS}

# Enable access to MQ 
source /opt/${env}/mqm/bin/setmqenv -s
#source mqsi profile
source /opt/${env}/iib/server/bin/mqsiprofile

doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o AGENT" 
doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o ACCTIONREPLICA"
doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o CALCULATEPREMIUM"
doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o COMMONEMAIL"
doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o DRUGAPPROVAL"
doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o ELECDOC"
doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o EMPLOYER"
doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o EXTRACT"
doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o INJUREDWORKER"
doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o INVOICE"
doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o INVOICELINEITEM"
doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o NETWORKMANAGEMENT"
doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o PAYEE"
doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o PRACTICELOCATION"
doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o PREMIUMPARAMETERS"
doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o PREMIUMREFERENCEDATA"
doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o PREMIUMTRANSACTION"
doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o PRICINGPERIODDATA"
doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o PROVIDER"
doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o PROVIDERAGREEMENT"
doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o QAS"
doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o REFERENCEDATA"
doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o REPOSITORY"
doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o REPOSITORYEXTRACT"
doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o SERVICEITEM"
doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o SERVICELIMIT"
doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o SUBMITINVOICE"
doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o TRANSPORTACCIDENTCLAIM"
doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o WORKINJURYCLAIM"
doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o WORKPLACE"

doMqsiExec "${MQSI_BIN_LOC}/mqsideleteconfigurableservice ${INTEGRATION_NODE_NAME} -c SecurityProfiles -o CONSUMER_NOVUS"

echo "==========================================================="
echo "Security deleteconfigurableservice completed successfully"

#!/bin/bash

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

brokerStatus()
{
  #"Running" or "Stopped"
  #su - ${IIB_ADMIN_USER} -c "mqsilist | grep ${INTEGRATION_NODE_NAME}" | awk '{print $NF}' | cut -d. -f1
  ps -ef | grep ${INTEGRATION_NODE_NAME} | grep bipbroker > /dev/null; if [ $? -eq 0 ]; then echo Running; else echo Stopped; fi
}

source /opt/${env}/iib/server/bin/mqsiprofile
# echo "source /opt/${env}/iib/server/bin/mqsiprofile" >> ~/.bashrc

						
#ACCtionReplica  DataSource
doMqsiExec "${MQSI_BIN_LOC}/mqsisetdbparms ${INTEGRATION_NODE_NAME} -n ${AR_ODBC_SEC_NAME} -u ${AR_USER_NAME} -p ${AR_USER_PASSWORD}"

#TEMPUS DataSource
doMqsiExec "${MQSI_BIN_LOC}/mqsisetdbparms ${INTEGRATION_NODE_NAME} -n ${TPC2_ODBC_SEC_NAME} -u ${TPC2_USER_NAME} -p ${TPC2_USER_PASSWORD}"

#HICAPS DataSource
doMqsiExec "${MQSI_BIN_LOC}/mqsisetdbparms ${INTEGRATION_NODE_NAME} -n ${HICAPS_DSN_NAME} -u ${HICAPS_USER_NAME} -p ${HICAPS_USER_PASSWORD}"



# -----------------------------------------------------------------------#
# Restart to activate the new configuration
#
echo "restart integration node"
doMqsiExec "${MQSI_BIN_LOC}/mqsistop ${INTEGRATION_NODE_NAME}"

doMqsiExec "${MQSI_BIN_LOC}/mqsistart ${INTEGRATION_NODE_NAME}"


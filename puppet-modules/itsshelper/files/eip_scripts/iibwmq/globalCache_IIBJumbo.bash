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
     echo "performing: su $IIB_ADMIN_USER -c "$cmd""
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

#set the global cache to none - configuration will be done in line with commands.
doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -b cachemanager -o CacheManager -n policy -v none"

echo "disable Catalog service"
doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -e IS-${env}-vwa -o ComIbmCacheManager -n enableCatalogService -v false"

echo "disable Container service"
doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -e IS-${env}-vwa -o ComIbmCacheManager -n enableContainerService -v false"

echo "disable JMX capability"
doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -e IS-${env}-vwa -o ComIbmCacheManager -n enableJMX -v false"

echo "set the domainName"
doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -e IS-${env}-vwa -o ComIbmCacheManager -n domainName -v WMB_${CACHE_NODE_NAME}_${CACHE_NODE_IP}_${GC_PORT4}_${CACHE_NODE_NAME}_${CACHE_NODE_IP}_${GC_PORT8}"

echo "set the connectionEndPoints"
doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -e IS-${env}-vwa -o ComIbmCacheManager -n connectionEndPoints -v \\\"${CACHE_NODE_IP}:${GC_PORT4},${CACHE_NODE_IP}:${GC_PORT8}\\\""

echo "restart integration node"
doMqsiExec "${MQSI_BIN_LOC}/mqsistop ${INTEGRATION_NODE_NAME}"
doMqsiExec "${MQSI_BIN_LOC}/mqsistart ${INTEGRATION_NODE_NAME}"

echo "display the new configuration"
doMqsiExec "${MQSI_BIN_LOC}/mqsireportproperties ${INTEGRATION_NODE_NAME} -e IS-${env}-vwa -o ComIbmCacheManager -r"

echo "Global cache configuration completed successfully"
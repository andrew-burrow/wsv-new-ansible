#!/bin/bash

MQ_ADMIN_USER=mqm
ENV=$1
BRK_ID=$2
IS_ID=$3
# env is the environment name forced to lower case
env=${ENV,,}
# ENV is the environment name forced to upper case in case we need it
ENV=${env^^}
# brk_id is the BrokerIdentifier name forced to lower case
brk_id=${BRK_ID,,}
# is_id is the Integration server final name component forced to lower case
is_id=${IS_ID,,}
# BRK_ID is the Integration server final name component forced to upper case in case we need it
IS_ID=${is_id^^}
IIB_ADMIN_USER=iibadmin
QMGR_EXISTS=12

ROOTDIR=$(dirname $0)
MQSI_ROOT=/opt/${env}/iib/server
MQSI_BIN_LOC=${MQSI_ROOT}/bin

usage()
{
  echo "USAGE: $(basename $0) environment brokerIdentifier egIdentifier <scriptMode>"
  echo "where"
  echo "        environment is a 3-or-less-character label denoting an environment"
  echo "        brokerIdentifier is one the following options DEFAULT | RAD | JUMBO"
  echo "        egIdentifier is one the following options common | tac | vwa"
  echo "        scriptMode is one the following options CREATE | UPDATE"
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
if [ $# -ne 3 ] && [ $# -ne 4 ] ; then
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
# check execution group Identifier
#
if [ "$is_id" != 'common' ] && [ "$is_id" != 'tac' ] && [ "$is_id" != 'vwa' ] ; then
  usage
  exit 1
fi

# -----------------------------------------------------------------------#
# Initialise
source ${ROOTDIR}/build_common.bash
initVars IIB create

# -----------------------------------------------------------------------#
# config access to property file
#
PROPS=${CONFIGDIR}/IntegrationNodeConfig-${brk_id}-${env}.properties
if [ ! -f $PROPS ] ; then
  echo "ERROR: properties file not found: $PROPS"
  exit 1
fi

source ${PROPS}

# -----------------------------------------------------------------------#
# config access to IIB EG settings file
#
SETTINGS=${CONFIGDIR}/IntegrationServerConfig-${brk_id}-${env}-${is_id}.properties
if [ ! -f $SETTINGS ] ; then
  echo "ERROR: properties file not found: $SETTINGS"
  exit 1
fi


# -----------------------------------------------------------------------#
# Enable access to broker commands (mqsi)
#
source /opt/${env}/iib/server/bin/mqsiprofile


# -----------------------------------------------------------------------#
# get broker status
#
brokerStatus()
{
  #"Running" or "Stopped"
  ps -ef | grep ${INTEGRATION_NODE_NAME} | grep bipbroker > /dev/null; if [ $? -eq 0 ]; then echo Running; else echo Stopped; fi
}

# -----------------------------------------------------------------------#
# check broker exists
#
brokerExists()
{
  /opt/${env}/iib/server/bin/mqsireportbroker ${INTEGRATION_NODE_NAME} > /dev/null 2>&1

  if [ $? -eq 0 ]; then
    echo "true"
  else
    echo "false"
  fi
}

BROKER_EXISTS=$(brokerExists)
if [ ${BROKER_EXISTS} == 'true' ] ; then
  BROKER_STATUS=$(brokerStatus)
  echo "BROKER_STATUS: $BROKER_STATUS"
  if [ "$BROKER_STATUS" != "Running" ]; then
    echo "Broker must be running before configuring an Integration Server"
        exit 1
  fi
else
  echo "Broker must be exist before configuring an Integration Server"
  exit 1
fi

# -----------------------------------------------------------------------#
#read the properties file, and change properties for each valid line in the file
#
EG="IS-${env}-${is_id}"
ChangeCount=0
while read Object Property Value ; do
  if [ ${#Object} -gt 0 -a "${Object:0:1}" != '#' -a ${#Property} -gt 0 -a ${#Value} -gt 0 ] ; then
    echo "Checking property ${Property} on EG: ${EG}"
	CurrentVal=$(doMqsiExec "${MQSI_BIN_LOC}/mqsireportproperties ${INTEGRATION_NODE_NAME} -e ${EG} -o ${Object} -n ${Property}" | \
	  grep -v "^$\|^BIP\|^======\|^performing" )
	  
	if [ "${CurrentVal}" = "${Value}" ] ; then
	  echo "Property ${Property} on EG: ${EG} already set correctly to ${Value}, no action required"
	else
      echo "Setting property ${Property} on EG: ${EG}"

      doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -e ${EG} -o ${Object} -n ${Property} -v ${Value}"

      (( ChangeCount=ChangeCount + 1 ))
    fi
  fi
done < ${SETTINGS}

# -----------------------------------------------------------------------#
# Restart to activate the new configuration
#
if [ $ChangeCount -gt 0 ] ; then
  echo "restart integration server"
  doMqsiExec "${MQSI_BIN_LOC}/mqsistopmsgflow ${INTEGRATION_NODE_NAME} -e ${EG} -w 600"

  doMqsiExec "${MQSI_BIN_LOC}/mqsistartmsgflow ${INTEGRATION_NODE_NAME} -e ${EG} -w 600"

fi

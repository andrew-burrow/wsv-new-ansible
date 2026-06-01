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

# -----------------------------------------------------------------------#
# TODO:CHECK env set
#

source /opt/${env}/iib/server/bin/mqsiprofile

sed -i "/local7/a\ \n#IIB Redirect to /var/iib/logs\nuser.info     /var/iib/logs/iib.log\n\n" /etc/rsyslog.conf
service rsyslog restart
mkdir /var/iib/logs/
chmod -R 774 /var/iib/logs/
		
echo "restart integration node"
doMqsiExec "${MQSI_BIN_LOC}/mqsistop ${INTEGRATION_NODE_NAME}"
doMqsiExec "${MQSI_BIN_LOC}/mqsistart ${INTEGRATION_NODE_NAME}"

echo "==========================================================="
echo "IIB logs have been redirected successfully"
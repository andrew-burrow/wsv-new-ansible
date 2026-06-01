#!/bin/bash

MQ_ADMIN_USER=mqm
ENV=$1
env=${ENV,,}
ENV=${env^^}
IIB_ADMIN_USER=iibadmin
QMGR_EXISTS=12

ROOTDIR=$(dirname $0)

# Import Subroutines
#
source ${ROOTDIR}/build_common.bash
initVars IIB delete

MQSI_ROOT=/opt/${env}/iib/server
MQSI_BIN_LOC=${MQSI_ROOT}/bin

usage()
{
  echo "USAGE: $(basename $0) env"
}

doMqmExec()
{
     cmd=$1
     
     echo "==========================================================="
     echo "performing: $cmd"
     su - $MQ_ADMIN_USER -c "$cmd"
     if [ $? -ne 0 ]; then
       echo "ERROR executing command: ${cmd}"
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
# load property file
#
PROPS=${CONFIGDIR}/IIB_${env}_config.properties
if [ ! -f $PROPS ] ; then
  echo "ERROR: props file not found: $PROPS"
  exit 1
fi

source $PROPS

# -----------------------------------------------------------------------#
# check qmgr exist
#
qmgrExists()
{
  /opt/${env}/mqm/bin/dspmq -m "$QMGR_NAME" > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "true"
  else
    echo "false"
  fi
}

if [ $(qmgrExists) == "false"  ]; then
  echo "ERROR : QMGR ${QMGR_NAME} does not exists..."
  echo "Exiting script..."
  exit 1
else
  echo "QMGR ${QMGR_NAME} exists..."
fi

# -----------------------------------------------------------------------#
# start QUEUE MANAGER
#
qmgrStatus()
{
  /opt/${env}/mqm/bin/dspmq -m ${QMGR_NAME} | sed 's/.*STATUS(\(.*\))/\1/'
}

# TODO : WHAT is IT?
#if [ $# -ne 1 ];then
#  usage
#  exit 1
#fi

if [ "$(qmgrStatus)" != "Running" ]; then
  doMqmExec "/opt/${env}/mqm/bin/strmqm ${QMGR_NAME}"
else
  echo "QMGR ${QMGR_NAME} already started..."
fi

# -----------------------------------------------------------------------#
# TODO:CHECK ENV set
#

source ${MQSI_BIN_LOC}/mqsiprofile
#echo "source /opt/ibm_dev/mqsi/bin/mqsiprofile" >> ~/.bashrc


# -----------------------------------------------------------------------#
# delete Integration Node
#

#TODO
#INTEGRATION_NODE_WORK_PATH must exisit in installation ?? maybe not
#INTEGRATION_NODE_USER_LIB_PATH must exisit in insstallation 

brokerExists()
{
	brokerUUID=$(su $IIB_ADMIN_USER -c "mqsireportbroker ${INTEGRATION_NODE_NAME}" | sed -n '/node UUID/=')
  
	if [ !  -z "$brokerUUID" ];
		then 
			echo "true"
		else 
			echo "false"
	fi
}

if [ $(brokerExists) == "true"  ]; 
	then
		#TODO http port? and all other possbile confg
		#http://www-01.ibm.com/support/knowledgecenter/SSMKHH_9.0.0/com.ibm.etools.mft.doc/an28135_.htm
		
		#stop
		doMqsiExec "${MQSI_BIN_LOC}/mqsistop ${INTEGRATION_NODE_NAME}"

		# delete broker and queue manager
		doMqsiExec "${MQSI_BIN_LOC}/mqsideletebroker ${INTEGRATION_NODE_NAME} -w"
				
	else
		echo "Integration Node ${INTEGRATION_NODE_NAME} does not exist..."
fi


# -----------------------------------------------------------------------#
#
# TODO : clean up other remaining filesystem components
# drwxrws---. 6 iibadmin_sit mqbrkrs    4096 Jan 27 23:29 sit
# to
# drwxrws---. 6 mqm mqbrkrs    4096 Jan 27 23:29 sit
#
rm -rf /var/mqsi/${env}/ssl

# -----------------------------------------------------------------------#
# Remove init.d script and rc?.d auto start/stop
#

chkconfig --del iib_${INTEGRATION_NODE_NAME}
rm -f /etc/init.d/iib_${INTEGRATION_NODE_NAME}


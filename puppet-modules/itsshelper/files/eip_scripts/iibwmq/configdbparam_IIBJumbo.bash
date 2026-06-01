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
	 
	 # Set up array of allowed response codes
	 declare -A goodCodes
	 goodCodes[0]=1
	 shift
	 while [ ! -z "$1" ] ; do
		goodCodes[$1]=1
		shift
	 done
	  
     
     echo "==========================================================="
     echo "performing: su $IIB_ADMIN_USER -c $cmd"
     su $IIB_ADMIN_USER -c "$cmd"
	 res=$?
     if [ -z "${goodCodes[$res]}" ]; then
       echo "ERROR executing command: ${cmd}"
	   echo "Shell Return code $res"
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

brokerStatus()
{
  #"Running" or "Stopped"
  #su - ${IIB_ADMIN_USER} -c "mqsilist | grep ${INTEGRATION_NODE_NAME}" | awk '{print $NF}' | cut -d. -f1
  ps -ef | grep ${INTEGRATION_NODE_NAME} | grep bipbroker > /dev/null; if [ $? -eq 0 ]; then echo Running; else echo Stopped; fi
}

source /opt/${env}/iib/server/bin/mqsiprofile
# echo "source /opt/${env}/iib/server/bin/mqsiprofile" >> ~/.bashrc

#TEMPUS DataSource (for EIP_CONFIG table to load run time configuration data)
doMqsiExec "${MQSI_BIN_LOC}/mqsisetdbparms ${INTEGRATION_NODE_NAME} -n ${TPC2_ODBC_SEC_NAME} -u ${TPC2_USER_NAME} -p ${TPC2_USER_PASSWORD}"

# Create whatever SFTP configurable services and credential sets are specified in the config file
for SVNAME in ${SFTP_LIST[*]} ; do
	# Set default protocol
	if [ -z ${SFTP_PROTOCOL[$SVNAME]} ] ; then
		SFTPPROTOCOL="sftp"
	else
		SFTPPROTOCOL=${SFTP_PROTOCOL[$SVNAME]}
	fi
	# Credentials
	if [ ! -z "${SFTP_CREDNAME[$SVNAME]}" ] ; then
		# There is a credential name, so we might have to create one
		if [ ! -z "${SFTP_USERID[$SVNAME]}" ] ; then
			# Only create the credentials if the USERID is defined. This allows reuse of credentials
			if [ -z "${SFTP_PASSWD[$SVNAME]}" ] ; then
				# Password is not set, so use RSA
				# Set up sftp authentication using RSA key
				# If passphrase is "RANDOM" or empty, Generate a random passphrase
				if [ -z "${SFTP_PASSPHRASE[$SVNAME]}" -o "${SFTP_PASSPHRASE[$SVNAME]}" = "RANDOM" ] ; then
					source /opt/${env}/mqm/bin/setmqenv -s
					PASSPHRASE=$(runmqakm -random -create -length 60 -strong \
							| tr -d "'" | tr -d '\\\$\%\`\~\&\@\!\|\\[\]\(\)\{\}\;",*<># ' \
							| cut -c 2-31)
				else
					PASSPHRASE=${SFTP_PASSPHRASE[$SVNAME]}
				fi
				doMqsiExec "rm -f ${SFTP_IDFILE[$SVNAME]}*"
				doMqsiExec "ssh-keygen -q -b 2048 -t rsa -N ${PASSPHRASE} -C \"sftp key for ${SFTP_CREDNAME[$SVNAME]} user ${SFTP_USERID[$SVNAME]}\" -f ${SFTP_IDFILE[$SVNAME]}"
				doMqsiExec "${MQSI_BIN_LOC}/mqsisetdbparms ${INTEGRATION_NODE_NAME} -n ${SFTPPROTOCOL}::${SFTP_CREDNAME[$SVNAME]} -u ${SFTP_USERID[$SVNAME]} -i ${SFTP_IDFILE[$SVNAME]} -r ${PASSPHRASE}"
			else
				# Set up sftp authentication using password
				doMqsiExec "${MQSI_BIN_LOC}/mqsisetdbparms ${INTEGRATION_NODE_NAME} -n ${SFTPPROTOCOL}::${SFTP_CREDNAME[$SVNAME]} -u ${SFTP_USERID[$SVNAME]} -p ${SFTP_PASSWD[$SVNAME]}"
			fi
			doMqsiExec "${MQSI_BIN_LOC}/mqsireportdbparms ${INTEGRATION_NODE_NAME} -n ${SFTPPROTOCOL}::${SFTP_CREDNAME[$SVNAME]}"
		fi
	fi
	# Configurable Service details
	if [ ! -z "${SFTP_CONFSERVNAME[$SVNAME]}" ] ; then
		doMqsiExec "${MQSI_BIN_LOC}/mqsicreateconfigurableservice ${INTEGRATION_NODE_NAME} -c FtpServer -o ${SFTP_CONFSERVNAME[$SVNAME]}" 36
		doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -c FtpServer -o ${SFTP_CONFSERVNAME[$SVNAME]} -n cipher -v \"${SFTP_CIPHER[$SVNAME]}\""
		doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -c FtpServer -o ${SFTP_CONFSERVNAME[$SVNAME]} -n mac -v \"${SFTP_MAC[$SVNAME]}\""
		doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -c FtpServer -o ${SFTP_CONFSERVNAME[$SVNAME]} -n protocol -v \"${SFTPPROTOCOL}\""
		if [ ! -z "${SFTP_PORT[$SVNAME]}" ] ; then
			SFTPPORT=":${SFTP_PORT[$SVNAME]}"
		else
			SFTPPORT=""
		fi
		doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -c FtpServer -o ${SFTP_CONFSERVNAME[$SVNAME]} -n serverName -v \"${SFTP_HOSTNAME[$SVNAME]}$SFTPPORT\""
		doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -c FtpServer -o ${SFTP_CONFSERVNAME[$SVNAME]} -n knownHostsFile -v \"${SFTP_KNOWNHOSTS[$SVNAME]}\""
		doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -c FtpServer -o ${SFTP_CONFSERVNAME[$SVNAME]} -n strictHostKeyChecking -v \"${SFTP_STRICTHOSTKEYCHECK[$SVNAME]}\""
		doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -c FtpServer -o ${SFTP_CONFSERVNAME[$SVNAME]} -n timeoutSec -v \"${SFTP_TIMEOUT[$SVNAME]}\""
		doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -c FtpServer -o ${SFTP_CONFSERVNAME[$SVNAME]} -n securityIdentity -v \"${SFTP_CREDNAME[$SVNAME]}\""
		
		# Display the new status of the configurable service values
		doMqsiExec "${MQSI_BIN_LOC}/mqsireportproperties ${INTEGRATION_NODE_NAME} -c FtpServer -o ${SFTP_CONFSERVNAME[$SVNAME]} -r"
	fi
done


# -----------------------------------------------------------------------#
# Restart to activate the new configuration
#
echo "restart integration node"
doMqsiExec "${MQSI_BIN_LOC}/mqsistop ${INTEGRATION_NODE_NAME}"

doMqsiExec "${MQSI_BIN_LOC}/mqsistart ${INTEGRATION_NODE_NAME}"


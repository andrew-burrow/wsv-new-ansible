#!/bin/bash

ENV=$1
BRK_ID=$2
WLM_PROPS=$3

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

usage()
{
  echo "USAGE: $(basename $0) environment brokerIdentifier"
  echo "where"
  echo "	environment is a 3-or-less-character label denoting an environment"
  echo "	brokerIdentifier is one the following options DEFAULT | RAD | JUMBO"
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
if [ $# -ne 2 ] ; then
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
# create sftp Security Ids
#

# clean security directory if script is running in create mode
for SFTP_CRED in ${SFTP_CRED_LIST[*]} ; do
  echo "Checking for Security Id sftp::${SFTP_CREDNAME[$SFTP_CRED]}"
  su $IIB_ADMIN_USER -c "${MQSI_BIN_LOC}/mqsireportdbparms ${INTEGRATION_NODE_NAME} -n sftp::${SFTP_CREDNAME[$SFTP_CRED]} | grep userID > /dev/null 2>&1"
  if [ $? -ne 0 ] || [ ${SFTP_CONFIGMODE[$SFTP_CRED]} == 'REGENERATE' ] ; then
    rm -f ${SFTP_IDFILE[$SFTP_CRED]}*
    PASSPHRASE=$(runmqakm -random -create -length 60 -strong \
                | tr -d "'" | tr -d '\\\$\%\`\~\&\@\!\|\\[\]\(\)\{\}\;",*<># ' \
                | cut -c 2-31)
    doMqsiExec "ssh-keygen -q -b 2048 -t rsa -N ${PASSPHRASE} -C \"sftp key for ${SFTP_CREDNAME[$SFTP_CRED]} user ${SFTP_USERID[$SFTP_CRED]} from ${INTEGRATION_NODE_NAME}\" -f ${SFTP_IDFILE[$SFTP_CRED]}"
    doMqsiExec "${MQSI_BIN_LOC}/mqsisetdbparms ${INTEGRATION_NODE_NAME} -n sftp::${SFTP_CREDNAME[$SFTP_CRED]} -u ${SFTP_USERID[$SFTP_CRED]} -i ${SFTP_IDFILE[$SFTP_CRED]} -r ${PASSPHRASE}"

    echo "Share the public key ${SFTP_IDFILE[$SFTP_CRED]}.pub with UXC for configuration of the SFTP Server"
  fi
done

# -----------------------------------------------------------------------#
# create/update sftp server (configurable service)
#
for SFTP_CONFSRV in ${SFTP_CONFSRV_LIST[*]} ; do
  echo "Checking for SFTP Configurable Service ${SFTP_CONFSRV_NAME[$SFTP_CONFSRV]}"
  su $IIB_ADMIN_USER -c "${MQSI_BIN_LOC}/mqsireportproperties ${INTEGRATION_NODE_NAME} -c FtpServer -o ${SFTP_CONFSRV_NAME[$SFTP_CONFSRV]} -r > /dev/null 2>&1"
  if [ $? -ne 0 ] ; then
    doMqsiExec "${MQSI_BIN_LOC}/mqsicreateconfigurableservice ${INTEGRATION_NODE_NAME} -c FtpServer -o ${SFTP_CONFSRV_NAME[$SFTP_CONFSRV]}"
  fi

  doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -c FtpServer -o ${SFTP_CONFSRV_NAME[$SFTP_CONFSRV]} -n cipher,mac,protocol -v ${SFTP_CIPHER[$SFTP_CONFSRV]},${SFTP_MAC[$SFTP_CONFSRV]},sftp"
  doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -c FtpServer -o ${SFTP_CONFSRV_NAME[$SFTP_CONFSRV]} -n serverName,strictHostKeyChecking,timeoutSec,securityIdentity -v ${SFTP_SERVER[$SFTP_CONFSRV]},${SFTP_STRICTHOSTKEYCHECK[$SFTP_CONFSRV]},${SFTP_TIMEOUT[$SFTP_CONFSRV]},${SFTP_SECURITYID[$SFTP_CONFSRV]}"

  # Display the configurable service
  doMqsiExec "${MQSI_BIN_LOC}/mqsireportproperties ${INTEGRATION_NODE_NAME} -c FtpServer -o ${SFTP_CONFSRV_NAME[$SFTP_CONFSRV]} -r"
done

# -----------------------------------------------------------------------#
# create/update ftp server (configurable service)
#
for FTP_CONFSRV in ${FTP_CONFSRV_LIST[*]} ; do
  echo "Checking for FTP Configurable Service ${FTP_CONFSRV_NAME[$FTP_CONFSRV]}"
  su $IIB_ADMIN_USER -c "${MQSI_BIN_LOC}/mqsireportproperties ${INTEGRATION_NODE_NAME} -c FtpServer -o ${FTP_CONFSRV_NAME[$FTP_CONFSRV]} -r > /dev/null 2>&1"
  if [ $? -ne 0 ] ; then
    doMqsiExec "${MQSI_BIN_LOC}/mqsicreateconfigurableservice ${INTEGRATION_NODE_NAME} -c FtpServer -o ${FTP_CONFSRV_NAME[$FTP_CONFSRV]}"
  fi

  # Set Security Credentials for FTP 
  doMqsiExec "${MQSI_BIN_LOC}/mqsisetdbparms ${INTEGRATION_NODE_NAME} -n ftp::${FTP_SECURITYID[$FTP_CONFSRV]} -u ${FTP_USER[$FTP_CONFSRV]} -p $(decryptPwd ${FTP_PWD[$FTP_CONFSRV]})"

  doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -c FtpServer -o ${FTP_CONFSRV_NAME[$FTP_CONFSRV]} -n protocol -v FTP"
  doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -c FtpServer -o ${FTP_CONFSRV_NAME[$FTP_CONFSRV]} -n serverName,connectionType,timeoutSec,transferMode,securityIdentity -v ${FTP_SERVER[$FTP_CONFSRV]},${FTP_CONN_TYPE[$FTP_CONFSRV]},${FTP_TIMEOUT[$FTP_CONFSRV]},${FTP_XFER_MODE[$FTP_CONFSRV]},${FTP_SECURITYID[$FTP_CONFSRV]}"

  # Display the configurable service
  doMqsiExec "${MQSI_BIN_LOC}/mqsireportproperties ${INTEGRATION_NODE_NAME} -c FtpServer -o ${FTP_CONFSRV_NAME[$FTP_CONFSRV]} -r"
done

# -----------------------------------------------------------------------#
# Restart to activate the new configuration
#
echo "restart integration node"
doMqsiExec "${MQSI_BIN_LOC}/mqsistop ${INTEGRATION_NODE_NAME}"

doMqsiExec "${MQSI_BIN_LOC}/mqsistart ${INTEGRATION_NODE_NAME}"

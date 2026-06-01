#!/bin/bash

MQ_ADMIN_USER=mqm
ENV=$1
BRK_ID=$2
SCRIPT_MODE=${3:-UPDATE}
# env is the environment name forced to lower case
env=${ENV,,}
# ENV is the environment name forced to upper case in case we need it
ENV=${env^^}
# brk_id is the BrokerIdentifier name forced to lower case
brk_id=${BRK_ID,,}
# script_mode is the ScriptMode name forced to lower case
script_mode=${SCRIPT_MODE,,}
IIB_ADMIN_USER=iibadmin
QMGR_EXISTS=12

ROOTDIR=$(dirname $0)
MQSI_ROOT=/opt/${env}/iib/server
MQSI_BIN_LOC=${MQSI_ROOT}/bin

usage()
{
  echo "USAGE: $(basename $0) environment brokerIdentifier <scriptMode>"
  echo "where"
  echo "	environment is a 3-or-less-character label denoting an environment"
  echo "	brokerIdentifier is one the following options DEFAULT | RAD | JUMBO"
  echo "	scriptMode is one the following options CREATE | UPDATE"
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
if [ $# -ne 2 ] && [ $# -ne 3 ] ; then
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
# check Script Mode
#
if [ "$script_mode" != 'create' ] && [ "$script_mode" != 'update' ] ; then
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

# Enable access to MQ
source /opt/${env}/mqm/bin/setmqenv -s

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
  echo "INFO : QMGR ${QMGR_NAME} does not exist...It must be created with createQMGR.bash..."
  echo "Giving up. Restart once qmgr is created"
  exit 1
else
  echo "QMGR ${QMGR_NAME} exists..."
fi

# -----------------------------------------------------------------------#
# check qmgr status
#
qmgrStatus()
{
  /opt/${env}/mqm/bin/dspmq -m ${QMGR_NAME} | sed 's/.*STATUS(\(.*\))/\1/'
}

if [ "$(qmgrStatus)" != "Running" ]; then
  doMqmExec "/opt/${env}/mqm/bin/strmqm ${QMGR_NAME}"
else
  echo "QMGR ${QMGR_NAME} already started..."
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
if [ ${BROKER_EXISTS} == 'true' ] && [ ${script_mode} == 'create' ] ; then
  #Stop
  BROKER_STATUS=$(brokerStatus)
  echo "BROKER_STATUS: $BROKER_STATUS"
  if [ "$BROKER_STATUS" = "Running" ]; then
    doMqsiExec "${MQSI_BIN_LOC}/mqsistop ${INTEGRATION_NODE_NAME}"
  fi
  echo "Deleting ${INTEGRATION_NODE_NAME}..."
  doMqsiExec "${MQSI_BIN_LOC}/mqsideletebroker ${INTEGRATION_NODE_NAME} -w"

  # Set to false for re-creation
  BROKER_EXISTS=false
fi

# -----------------------------------------------------------------------#
# create Integration Node
#
if [ ${BROKER_EXISTS} == 'false' ] ; then
  doMqsiExec "${MQSI_BIN_LOC}/mqsicreatebroker ${INTEGRATION_NODE_NAME} -q ${QMGR_NAME} -w ${INTEGRATION_NODE_WORK_PATH} -l ${INTEGRATION_NODE_USER_LIB_PATH} -o ${INTEGRATION_NODE_MODE}"
fi

# Start Integration Node
BROKER_STATUS=$(brokerStatus)
if [ "$BROKER_STATUS" = "Stopped" ] ; then
  doMqsiExec "${MQSI_BIN_LOC}/mqsistart ${INTEGRATION_NODE_NAME}"
fi

# -----------------------------------------------------------------------#
# Create Configurable Service for SMTP server
#
for SMTP in ${SMTP_LIST[*]} ; do
  echo "Working on SMTP Service: ${SMTP_SERVICE_NAME[$SMTP]}"
  su $IIB_ADMIN_USER -c "${MQSI_BIN_LOC}/mqsireportproperties ${INTEGRATION_NODE_NAME} -c SMTP -o ${SMTP_SERVICE_NAME[$SMTP]} -r > /dev/null 2>&1"
  if [ $? -ne 0 ] ; then
    doMqsiExec "${MQSI_BIN_LOC}/mqsicreateconfigurableservice ${INTEGRATION_NODE_NAME} -c SMTP -o ${SMTP_SERVICE_NAME[$SMTP]} -n serverName -v ${SMTP_SERVER[$SMTP]}"
  else
    doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -c SMTP -o ${SMTP_SERVICE_NAME[$SMTP]} -n serverName -v ${SMTP_SERVER[$SMTP]}"
  fi
done

# -----------------------------------------------------------------------#
# Create Configurable Service for TCPIP Client
#
for TCPIP_CLIENT in ${TCPIP_CLIENT_LIST[*]} ; do
  echo "Working on TCPIP Client Service: ${TCPIP_CLIENT_SERVICE_NAME[$TCPIP_CLIENT]}"
  su $IIB_ADMIN_USER -c "${MQSI_BIN_LOC}/mqsireportproperties ${INTEGRATION_NODE_NAME} -c TCPIPClient -o ${TCPIP_CLIENT_SERVICE_NAME[$TCPIP_CLIENT]} -r > /dev/null 2>&1"
  if [ $? -ne 0 ] ; then
    doMqsiExec "${MQSI_BIN_LOC}/mqsicreateconfigurableservice ${INTEGRATION_NODE_NAME} -c TCPIPClient -o ${TCPIP_CLIENT_SERVICE_NAME[$TCPIP_CLIENT]} -n Hostname,Port,MinimumConnections,SO_KEEPALIVE -v ${TCPIP_CLIENT_HOSTNAME[$TCPIP_CLIENT]},${TCPIP_CLIENT_PORT[$TCPIP_CLIENT]},1,true"
  else
    doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -c TCPIPClient -o ${TCPIP_CLIENT_SERVICE_NAME[$TCPIP_CLIENT]} -n Hostname,Port,MinimumConnections,SO_KEEPALIVE -v ${TCPIP_CLIENT_HOSTNAME[$TCPIP_CLIENT]},${TCPIP_CLIENT_PORT[$TCPIP_CLIENT]},1,true"
  fi
done

# -----------------------------------------------------------------------#
# Set LDAP details
if [ ${CONFIGURE_LDAP_FLG:-false} == 'true' ] ; then
  doMqsiExec "${MQSI_BIN_LOC}/mqsisetdbparms ${INTEGRATION_NODE_NAME} -n ldap::${LDAP_HOST} -u ${LDAP_BIND_USR} -p $(decryptPwd ${LDAP_BIND_PWD})"

  # Create Consumer Policy Set
  su $IIB_ADMIN_USER -c "${MQSI_BIN_LOC}/mqsireportproperties ${INTEGRATION_NODE_NAME} -c PolicySets -o WSConsumerDefault -a > /dev/null 2>&1"
  if [ $? -ne 0 ]; then
    doMqsiExec "${MQSI_BIN_LOC}/mqsicreateconfigurableservice ${INTEGRATION_NODE_NAME} -c PolicySets -o WSConsumerDefault"
  fi
  doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -c PolicySets -o WSConsumerDefault -n ws-security -p \"${CONFIGDIR}/WSConsumerPolicySet.xml\""

  # Create Consumer Policy Set Bindings
  su $IIB_ADMIN_USER -c "${MQSI_BIN_LOC}/mqsireportproperties ${INTEGRATION_NODE_NAME} -c PolicySetBindings -o WSConsumerDefault -a > /dev/null 2>&1"
  if [ $? -ne 0 ]; then
    doMqsiExec "${MQSI_BIN_LOC}/mqsicreateconfigurableservice ${INTEGRATION_NODE_NAME} -c PolicySetBindings -o WSConsumerDefault"
  fi
  doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -c PolicySetBindings -o WSConsumerDefault -n ws-security -p \"${CONFIGDIR}/WSConsumerPolicySetBinding.xml\""
  doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -c PolicySetBindings -o WSConsumerDefault -n associatedPolicySet -v WSConsumerDefault"

  # Create Consumer Policy Set Bindings (WithOut Must Understand)
  su $IIB_ADMIN_USER -c "${MQSI_BIN_LOC}/mqsireportproperties ${INTEGRATION_NODE_NAME} -c PolicySetBindings -o WSConsumerWOMustUnderstand -a > /dev/null 2>&1"
  if [ $? -ne 0 ]; then
    doMqsiExec "${MQSI_BIN_LOC}/mqsicreateconfigurableservice ${INTEGRATION_NODE_NAME} -c PolicySetBindings -o WSConsumerWOMustUnderstand"
  fi
  doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -c PolicySetBindings -o WSConsumerWOMustUnderstand -n ws-security -p \"${CONFIGDIR}/WSConsumerPolicySetBinding_WOMustUnderstand.xml\""
  doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -c PolicySetBindings -o WSConsumerWOMustUnderstand -n associatedPolicySet -v WSConsumerDefault"
fi

# -----------------------------------------------------------------------#
# Set HTTP connector and Listener properties at the Node level
#
doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -b httplistener -o HTTPListener -n startListener -v false"
doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -b httplistener -o HTTPConnector -n address,port -v ${INTEGRATION_NODE_IP},${INTEGRATION_NODE_HTTP_PORT}"

# -----------------------------------------------------------------------#
# Set Global Cache Policy
if [ ${CONFIGURE_CACHE_FLG:-false} == 'true' ] ; then
  doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -b cachemanager -o CacheManager -n policy -v none"
fi

# -----------------------------------------------------------------------#
#create Integration Servers and set jvm properties
#
for EG in ${EG_LIST[*]} ; do
  echo "Working on EG: ${EG_NAME[$EG]}"
  su $IIB_ADMIN_USER -c "${MQSI_BIN_LOC}/mqsilist ${INTEGRATION_NODE_NAME} | grep ${EG_NAME[$EG]} > /dev/null 2>&1"
  if [ $? -ne 0 ] ; then
    doMqsiExec "${MQSI_BIN_LOC}/mqsicreateexecutiongroup ${INTEGRATION_NODE_NAME} -e ${EG_NAME[$EG]}"
  fi

  # Set JVM settings
  # - Log4j and Eip-Config property file
  # - JVM Min/Max Heap size
  doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -e ${EG_NAME[$EG]} -o ComIbmJVMManager -n jvmSystemProperty -v \"-Xmn${JVM_NURSERY_SIZE[$EG]} -Xverbosegclog:${JVM_VERBOSE_TRACE[$EG]} -Dlog4j.configurationFile=${EIP_LOG4J_CONFIG[$EG]} -Deip.config=${INTEGRATION_NODE_CONFIG_DIR}/eip-config.xml\""
  doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -e ${EG_NAME[$EG]} -o ComIbmJVMManager -n jvmMaxHeapSize,jvmMinHeapSize -v ${JVM_MAX_HEAP_SIZE[$EG]},${JVM_MIN_HEAP_SIZE[$EG]}"
  doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -e ${EG_NAME[$EG]} -o ComIbmJVMManager -n jvmVerboseOption -v all"

  doMqsiExec "${MQSI_BIN_LOC}/mqsireportproperties ${INTEGRATION_NODE_NAME} -e ${EG_NAME[$EG]} -o ComIbmJVMManager -r"

  # Enable Embedded HTTP listener for each Integration Server and set HTTP Connector details
  if [ ${CONFIGURE_HTTP_FLG:-false} == 'true' ] ; then
    doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -e ${EG_NAME[$EG]} -o ExecutionGroup -n soapNodesUseEmbeddedListener,httpNodesUseEmbeddedListener -v true,true"
    doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -e ${EG_NAME[$EG]} -o HTTPConnector -n address,explicitlySetPortNumber -v ${INTEGRATION_NODE_IP},${HTTP_PORT[$EG]}"
  fi

  # Configure global cache
  if [ ${CONFIGURE_CACHE_FLG:-false} == 'true' ] ; then
    doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -e ${EG_NAME[$EG]} -o ComIbmCacheManager -n enableCatalogService,enableContainerService,enableJMX,listenerPort,listenerHost,haManagerPort,jmxServicePort -v ${GC_CATALOG_FLG[$EG]},${GC_CONTAINER_FLG[$EG]},${GC_JMX_FLG[$EG]},${GC_LISTENER_PORT[$EG]},${INTEGRATION_NODE_IP},${GC_HA_PORT[$EG]},${GC_JMX_PORT[$EG]}"
    doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -e ${EG_NAME[$EG]} -o ComIbmCacheManager -n domainName -v ${GC_DOMAIN_NAME}"
    doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -e ${EG_NAME[$EG]} -o ComIbmCacheManager -n connectionEndPoints -v \\\"${GC_CONN_END_POINTS}\\\""
    doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -e ${EG_NAME[$EG]} -o ComIbmCacheManager -n catalogClusterEndPoints -v \\\"${GC_CATALOG_CLUSTER_END_POINTS}\\\""
  doMqsiExec "${MQSI_BIN_LOC}/mqsireportproperties ${INTEGRATION_NODE_NAME} -e ${EG_NAME[$EG]} -o ComIbmCacheManager -r"
  fi
done

# -----------------------------------------------------------------------#
# create sftp Security Ids
#

# clean security directory if script is running in create mode
if [ ${script_mode} == 'create' ] ; then
  rm -rf ${INTEGRATION_NODE_CONFIG_DIR}/security/*
fi

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
  doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -c FtpServer -o ${SFTP_CONFSRV_NAME[$SFTP_CONFSRV]} -n serverName,connectionType,timeoutSec,transferMode,securityIdentity -v ${FTP_SERVER[$FTP_CONFSRV]},${FTP_CONN_TYPE[$FTP_CONFSRV]},${FTP_TIMEOUT[$FTP_CONFSRV]},${FTP_XFER_MODE[$FTP_CONFSRV]},${FTP_SECURITYID[$FTP_CONFSRV]}"

  # Display the configurable service
  doMqsiExec "${MQSI_BIN_LOC}/mqsireportproperties ${INTEGRATION_NODE_NAME} -c FtpServer -o ${FTP_CONFSRV_NAME[$FTP_CONFSRV]} -r"
done

# -----------------------------------------------------------------------#
# Enable SSL on the webadmin port
# First create a key store and key/certificate pair
# The setup will use autosigning information from the MQ config.
# Then set up the webadmin properties to use it all
if [ ! -d ${INTEGRATION_NODE_SSL_DIR} ] || [ ${script_mode} == 'create' ] ; then
  e=${HOSTNAME:1:1}
  E=${e^^}
  source ${MQSIGNINFO}
  MQAUTOSIGN=${MQAUTOSIGNLIST[$E]}
  MQCASERVER=${MQCASERVERLIST[$E]}
  MQCACREDFILE=${CONFIGDIR}/${MQCACREDFILELIST[$E]}
  MQCAUSERNAME=${MQCAUSERNAMELIST[$E]}

  if [ -d ${INTEGRATION_NODE_SSL_DIR} ] ; then
    rm -rf ${INTEGRATION_NODE_SSL_DIR}
  fi
  mkdir ${INTEGRATION_NODE_SSL_DIR}
  chown ${IIB_ADMIN_USER}:mqbrkrs ${INTEGRATION_NODE_SSL_DIR}
  chmod 700 ${INTEGRATION_NODE_SSL_DIR}

  # Create strong random passphrase
  runmqakm -random -create -length 125 -strong \
          | tr -d "'" | tr -d '\\\$\%\`\,\~\&\@\!\|\\[\]\(\)\{\}\;\>\<\/" ' \
          | cut -c 2-65 \
          > ${INTEGRATION_NODE_SSL_DIR}/webadmin.passwd
  # Create the keystore file
  runmqckm -keydb -create -db ${INTEGRATION_NODE_SSL_DIR}/webadmin.jks \
          -pw "`cat ${INTEGRATION_NODE_SSL_DIR}/webadmin.passwd`" \
          -type jks
  # Set ownership and tightest available security
  chown ${IIB_ADMIN_USER}:mqbrkrs ${INTEGRATION_NODE_SSL_DIR}/*
  chmod 600 ${INTEGRATION_NODE_SSL_DIR}/*
  # Add the VWA certificates
  # The arrays are declared and initialised in mqcacertlist.properties
  # This is included from the .prop file
  # The arrays are CA_Certs and CA_Labels
  source ${MQCACERTS}
  for (( i=0 ; i<${#CA_Certs[*]} ; i++ )) ; do
  	if [ ! -f ${CA_Certs[i]} ] ; then
      echo "Certificate file ${CA_Certs[i]} missing"
      echo "Check that ../properties directory is correctly built"
    else
      runmqckm -cert -add -db ${INTEGRATION_NODE_SSL_DIR}/webadmin.jks \
               -type jks \
               -pw "`cat ${INTEGRATION_NODE_SSL_DIR}/webadmin.passwd`" \
               -file ${CA_Certs[i]} \
               -label "${CA_Labels[i]}" \
               -trust enable
    fi
  done

  # -----------------------------------------------------------------------#
  # Generate Certificate Signing Request for the queue manager.
  # If autosigning is enabled (see mqcertsign.properties) then
  # sign the certificate using the CA and call createQMGRCert.bash
  # This will save the cert file and receive it into the qmgr key store.
  #
  runmqckm -certreq -create -db ${INTEGRATION_NODE_SSL_DIR}/webadmin.jks \
           -type jks \
           -pw "`cat ${INTEGRATION_NODE_SSL_DIR}/webadmin.passwd`" \
           -label ${INTEGRATION_NODE_NAME} \
           -dn "CN=${INTEGRATION_NODE_IP},OU=${INTEGRATION_NODE_CERT_OU},OU=IBM IIB,O=ITSS,L=Melbourne,ST=VIC,C=AU" \
           -file ${INTEGRATION_NODE_SSL_DIR}/${INTEGRATION_NODE_IP}.req \
           -sig_alg SHA256_WITH_RSA -size 2048
  res=$?
  if [ $res -eq 0 ] ; then
    # Reset CSR file ownership
    chown ${IIB_ADMIN_USER}:mqbrkrs ${INTEGRATION_NODE_SSL_DIR}/${INTEGRATION_NODE_IP}.req
    chmod 600 ${INTEGRATION_NODE_SSL_DIR}/${INTEGRATION_NODE_IP}.req
    echo
    echo "Certificate signing request created:"
    if [ "$MQAUTOSIGN" == "yes" ] ; then
      # Sign the certificate automatically using ssh to run
      # the 'sign' command
      cat ${INTEGRATION_NODE_SSL_DIR}/${INTEGRATION_NODE_IP}.req | \
          ( ssh $MQCAUSERNAME@$MQCASERVER -q -i $MQCACREDFILE \
            "vwaCA/sign ${INTEGRATION_NODE_IP} -q" ) \
          > ${INTEGRATION_NODE_SSL_DIR}/${INTEGRATION_NODE_IP}.cer
      res=$?
      if [ $res -ne 0 ] ; then
        echo "Unable to autosign certificate"
        echo "Giving up. You will need to fix the problem,"
        echo "delete the integration node and restart"
        exit 1
      fi
      runmqckm -cert -receive -db ${INTEGRATION_NODE_SSL_DIR}/webadmin.jks \
         -type jks \
         -pw "`cat ${INTEGRATION_NODE_SSL_DIR}/webadmin.passwd`" \
         -file ${INTEGRATION_NODE_SSL_DIR}/${INTEGRATION_NODE_IP}.cer
      res=$?
      if [ $res -ne 0 ] ; then
        echo "Unable to receive certificate"
        echo "Giving up. You will need to fix the problem,"
        echo "delete the integration node and restart"
        exit 1
      else
        echo "autosigned certificate received"
        CREDFILENAME=$(basename $MQCACREDFILE)
        cp $MQCACREDFILE $INTEGRATION_NODE_SSL_DIR/$CREDFILENAME
        chown ${IIB_ADMIN_USER}:mqbrkrs ${INTEGRATION_NODE_SSL_DIR}/$CREDFILENAME
        chmod 600 ${INTEGRATION_NODE_SSL_DIR}/$CREDFILENAME
        cat <<CACREDINFO > $INTEGRATION_NODE_SSL_DIR/ca.properties
CAUSER=$MQCAUSERNAME
CASERVER=$MQCASERVER
CACREDS=$INTEGRATION_NODE_SSL_DIR/$CREDFILENAME
CACREDINFO
        chown ${IIB_ADMIN_USER}:mqbrkrs ${INTEGRATION_NODE_SSL_DIR}/ca.properties
        chmod 600 ${INTEGRATION_NODE_SSL_DIR}/ca.properties
      fi
    else
      echo "Send file ${INTEGRATION_NODE_SSL_DIR}/${INTEGRATION_NODE_IP}.req to be signed by your CA"
    fi
  else
    echo "Failed to create certificate signing request."
    echo "Giving up. You will need to delete the integration node,"
    echo "fix the problem and start again."
    exit 1
  fi
fi

# -----------------------------------------------------------------------#
#Set webadmin to use SSL and enable webadmin service
doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -b webadmin -o server -n enableSSL,enabled -v true,true"

#Set HTTPS IP and Port for webadmin
doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -b webadmin -o HTTPSConnector -n address,port -v ${INTEGRATION_NODE_IP},${INTEGRATION_NODE_ADMIN_PORT}"

#Set keystore info for webadmin
doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} \
	-b webadmin -o HTTPSConnector \
	-n keystoreFile \
	-v ${INTEGRATION_NODE_SSL_DIR}/webadmin.jks"
doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} \
	-b webadmin -o HTTPSConnector \
	-n keystorePass \
	-v \"$(cat ${INTEGRATION_NODE_SSL_DIR}/webadmin.passwd)\""


# -----------------------------------------------------------------------#
# Configure trust store for Integration Node

cp ${CONFIGDIR}/brokerTrustStore.jks ${INTEGRATION_NODE_TRUST_STORE_FILE}
chown ${IIB_ADMIN_USER}:mqbrkrs ${INTEGRATION_NODE_TRUST_STORE_FILE}
chmod 600 ${INTEGRATION_NODE_TRUST_STORE_FILE}

doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -o BrokerRegistry -n brokerTruststoreFile -v \"${INTEGRATION_NODE_TRUST_STORE_FILE}\""

# Set the Integration Node trust store password
doMqsiExec "${MQSI_BIN_LOC}/mqsisetdbparms ${INTEGRATION_NODE_NAME} -n brokerTruststore::password -u ignore -p $(decryptPwd ${INTEGRATION_NODE_TRUST_STORE_PWD})"



# -----------------------------------------------------------------------#
# set /var/mqsi/<env> just created with creating message broker workpath
# if not, mqm or IBExplore will not able to access Integration Node
#
# TODO : make sure of this.
# drwxrws---. 6 iibadmin_sit mqbrkrs    4096 Jan 27 23:29 sit
# to
# drwxrws---. 6 mqm mqbrkrs    4096 Jan 27 23:29 sit
#

chown -R ${IIB_ADMIN_USER}:mqbrkrs ${INTEGRATION_NODE_WORK_PATH}
chmod -R ug+rwX ${INTEGRATION_NODE_WORK_PATH}

chmod g+s ${INTEGRATION_NODE_WORK_PATH}
find ${INTEGRATION_NODE_WORK_PATH} -type f -exec chmod g+s {} \;

# Update the access permissions for SSL directory
chmod 700 ${INTEGRATION_NODE_SSL_DIR}
chmod 600 ${INTEGRATION_NODE_SSL_DIR}/*

# Verify Integration Node settings
doMqsiExec "${MQSI_BIN_LOC}/mqsireportbroker ${INTEGRATION_NODE_NAME}"
doMqsiExec "${MQSI_BIN_LOC}/mqsilist ${INTEGRATION_NODE_NAME}"


# -----------------------------------------------------------------------#
# copy custom jars
#
echo "copy ${CUSTOM_JAR_LOC}/${CUSTOM_JAR_NAME[*]} to ${MQSI_ROOT}/jplugin/"
for (( i=0 ; i<${#CUSTOM_JAR_NAME[*]} ; i++ )) ; do
	cp ${CUSTOM_JAR_LOC}/${CUSTOM_JAR_NAME[i]} ${MQSI_ROOT}/jplugin/
done
chown $IIB_ADMIN_USER:mqbrkrs ${MQSI_ROOT}/jplugin/*
chmod 775 ${MQSI_ROOT}/jplugin/*

# -----------------------------------------------------------------------#
# copy shared-classes jars
#
echo "copy ${CUSTOM_JAR_LOC}/${SHARED_CLASSES_JAR_NAME[*]} to ${INTEGRATION_NODE_WORK_PATH}/shared-classes/"
for (( i=0 ; i<${#SHARED_CLASSES_JAR_NAME[*]} ; i++ )) ; do
	cp ${CUSTOM_JAR_LOC}/${SHARED_CLASSES_JAR_NAME[i]} ${INTEGRATION_NODE_WORK_PATH}/shared-classes
done
chown $IIB_ADMIN_USER:mqbrkrs ${INTEGRATION_NODE_WORK_PATH}/shared-classes/*
chmod 775 ${INTEGRATION_NODE_WORK_PATH}/shared-classes/*

# -----------------------------------------------------------------------#
# Create/Update IIB webadmin default local user
#
su $IIB_ADMIN_USER -c "${MQSI_BIN_LOC}/mqsiwebuseradmin ${INTEGRATION_NODE_NAME} -l -u ${INTEGRATION_NODE_DEPLOY_USR} | grep ${INTEGRATION_NODE_DEPLOY_USR}"
if [ $? -ne 0 ] ; then
  doMqsiExec "${MQSI_BIN_LOC}/mqsiwebuseradmin ${INTEGRATION_NODE_NAME} -c -u ${INTEGRATION_NODE_DEPLOY_USR} -r iibadmin -a $(decryptPwd ${INTEGRATION_NODE_DEPLOY_PWD})"
else
  doMqsiExec "${MQSI_BIN_LOC}/mqsiwebuseradmin ${INTEGRATION_NODE_NAME} -m -u ${INTEGRATION_NODE_DEPLOY_USR} -r iibadmin -a $(decryptPwd ${INTEGRATION_NODE_DEPLOY_PWD})"
fi

# -----------------------------------------------------------------------#
# Restart to activate the new configuration
#
echo "restart integration node"
doMqsiExec "${MQSI_BIN_LOC}/mqsistop ${INTEGRATION_NODE_NAME}"

#Activate authentication for webadmin
doMqsiExec "${MQSI_BIN_LOC}/mqsichangeauthmode ${INTEGRATION_NODE_NAME} \
	-s active -m file"

# update the Fixpack capability level to current Fix Pack level
doMqsiExec "${MQSI_BIN_LOC}/mqsichangebroker ${INTEGRATION_NODE_NAME} -f ${INTEGRATION_NODE_FP_LEVEL}"

doMqsiExec "${MQSI_BIN_LOC}/mqsistart ${INTEGRATION_NODE_NAME}"

# -----------------------------------------------------------------------#
# Create init.d script and rc?.d auto start/stop
#
if [ -e /etc/init.d/iib_${INTEGRATION_NODE_NAME} ] ; then
  rm -f /etc/init.d/iib_${INTEGRATION_NODE_NAME}
fi

ln -s /etc/init.d/iib.init /etc/init.d/iib_${INTEGRATION_NODE_NAME}
chkconfig --add iib_${INTEGRATION_NODE_NAME}

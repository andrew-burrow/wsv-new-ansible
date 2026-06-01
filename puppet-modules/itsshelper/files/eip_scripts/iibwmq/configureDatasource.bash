#!/bin/bash

MQ_ADMIN_USER=mqm
ENV=$1
BRK_ID=$2

# env is the environment name forced to lower case
env=${ENV,,}
# ENV is the environment name forced to upper case in case we need it
ENV=${env^^}
# brk_id is the BrokerIdentifier name forced to lower case
brk_id=${BRK_ID,,}

IIB_ADMIN_USER=iibadmin
QMGR_EXISTS=12

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
# Configure ODBC data sources
#
for DSN in ${DSN_LIST[*]} ; do
    doMqsiExec "${MQSI_BIN_LOC}/mqsisetdbparms ${INTEGRATION_NODE_NAME} -n ${DSN_NAME[${DSN}]} -u ${DSN_USER[${DSN}]} -p $(decryptPwd ${DSN_USER_PWD[${DSN}]})"
done


# -----------------------------------------------------------------------#
# Configure JDBC data sources
#
for JDBC_PROVIDER in ${JDBC_PROVIDER_LIST[*]} ; do
  echo "Working on JDBC Provider: ${JDBC_PROVIDER_NAME[${JDBC_PROVIDER}]}"
  doMqsiExec "${MQSI_BIN_LOC}/mqsisetdbparms ${INTEGRATION_NODE_NAME} -n jdbc::${JDBC_PROVIDER_NAME[${JDBC_PROVIDER}]}_SECURITY_ID -u ${JDBC_PROVIDER_USER[${JDBC_PROVIDER}]} -p $(decryptPwd ${JDBC_PROVIDER_PWD[${JDBC_PROVIDER}]})"

  # Create configurable service if not already existing
  su $IIB_ADMIN_USER -c "${MQSI_BIN_LOC}/mqsireportproperties ${INTEGRATION_NODE_NAME} -c JDBCProviders -o ${JDBC_PROVIDER_NAME[${JDBC_PROVIDER}]} -r > /dev/null 2>&1"
  if [ $? -ne 0 ] ; then
    doMqsiExec "${MQSI_BIN_LOC}/mqsicreateconfigurableservice ${INTEGRATION_NODE_NAME} -c JDBCProviders -o ${JDBC_PROVIDER_NAME[${JDBC_PROVIDER}]} -n connectionUrlFormat,databaseType,jarsURL,type4DatasourceClassName,type4DriverClassName,jdbcProviderXASupport -v jdbc:oracle:thin:[user]/[password]@//[serverName]:[portNumber]/[databaseName],Oracle,/opt/${env}/sqllib/java/oracle,oracle.jdbc.xa.client.OracleXADataSource,oracle.jdbc.OracleDriver,true"
  fi

  # Update the JDBC Config details
  doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -c JDBCProviders -o ${JDBC_PROVIDER_NAME[${JDBC_PROVIDER}]} -n databaseName,description,serverName,portNumber,maxConnectionPoolSize,securityIdentity -v ${JDBC_PROVIDER_DB_NAME[${JDBC_PROVIDER}]},\"${JDBC_PROVIDER_DESC[${JDBC_PROVIDER}]}\",${JDBC_PROVIDER_DB_SERVER[${JDBC_PROVIDER}]},${JDBC_PROVIDER_DB_PORT[${JDBC_PROVIDER}]},${JDBC_PROVIDER_CONN_POOL_SIZE[${JDBC_PROVIDER}]},${JDBC_PROVIDER_NAME[${JDBC_PROVIDER}]}_SECURITY_ID"

  # List all the changes
  doMqsiExec "${MQSI_BIN_LOC}/mqsireportproperties ${INTEGRATION_NODE_NAME} -c JDBCProviders -o ${JDBC_PROVIDER_NAME[${JDBC_PROVIDER}]} -r"
done

# -----------------------------------------------------------------------#
# Restart the Integration node
#
echo "restart integration node"
service iib_${INTEGRATION_NODE_NAME} restart

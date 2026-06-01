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
PROPS=${CONFIGDIR}/IIBJumbo_${env}_config.properties
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
# start QUEUE MANAGER
#
qmgrStatus()
{
  /opt/${env}/mqm/bin/dspmq -m ${QMGR_NAME} | sed 's/.*STATUS(\(.*\))/\1/'
}

brokerStatus()
{
  #"Running" or "Stopped"
  #su - ${IIB_ADMIN_USER} -c "mqsilist | grep ${INTEGRATION_NODE_NAME}" | awk '{print $NF}' | cut -d. -f1
  ps -ef | grep ${INTEGRATION_NODE_NAME} | grep bipbroker > /dev/null; if [ $? -eq 0 ]; then echo Running; else echo Stopped; fi
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
# TODO:CHECK env set
#

source /opt/${env}/iib/server/bin/mqsiprofile
# echo "source /opt/${env}/iib/server/bin/mqsiprofile" >> ~/.bashrc


# -----------------------------------------------------------------------#
# create Integration Node
#

#TODO
#INTEGRATION_NODE_WORK_PATH must exist in installation ?? maybe not
if [ ! -d $INTEGRATION_NODE_WORK_PATH ] ; then
	umask 022
	mkdir -p $INTEGRATION_NODE_WORK_PATH
	chown ${IIB_ADMIN_USER}:mqbrkrs $INTEGRATION_NODE_WORK_PATH
fi

#INTEGRATION_NODE_USER_LIB_PATH must exist in installation 

brokerExists()
{
	brokerUUID=$(su $IIB_ADMIN_USER -c "mqsireportbroker ${INTEGRATION_NODE_NAME}" | sed -n '/node UUID/=')
  
	if [ ! -z "$brokerUUID" ]; then 
		echo "true"
	else 
		echo "false"
	fi
}

if [ $(brokerExists) == "true"  ]; 
then
	#TODO http port? and all other possbile confg
	#http://www-01.ibm.com/support/knowledgecenter/SSMKHH_9.0.0/com.ibm.etools.mft.doc/an28135_.htm
		
	#Stop
	BROKER_STATUS=$(brokerStatus)
	echo "BROKER_STATUS: $BROKER_STATUS"
	if [ "$BROKER_STATUS" = "Running" ]; then
		doMqsiExec "${MQSI_BIN_LOC}/mqsistop ${INTEGRATION_NODE_NAME}"
	fi
	echo "Deleting ${INTEGRATION_NODE_NAME}..."
	doMqsiExec "${MQSI_BIN_LOC}/mqsideletebroker ${INTEGRATION_NODE_NAME} -w"
				
fi

# create broker
doMqsiExec "${MQSI_BIN_LOC}/mqsicreatebroker ${INTEGRATION_NODE_NAME} -q ${QMGR_NAME} -w ${INTEGRATION_NODE_WORK_PATH} -l ${INTEGRATION_NODE_USER_LIB_PATH} -o ${INTEGRATION_NODE_MODE}"
	
#Start
doMqsiExec "${MQSI_BIN_LOC}/mqsistart ${INTEGRATION_NODE_NAME}"
						
#TEMPUS ODBC DataSource
doMqsiExec "${MQSI_BIN_LOC}/mqsisetdbparms ${INTEGRATION_NODE_NAME} -n ${TPC2_ODBC_SEC_NAME} -u ${TPC2_USER_NAME} -p ${TPC2_USER_PASSWORD}"

#create Integration Server(s) and set jvm properties (there is only one for now, but leave the loop in place in case more get added)
for ISname in vwa ; do
	doMqsiExec "${MQSI_BIN_LOC}/mqsicreateexecutiongroup ${INTEGRATION_NODE_NAME} -e IS-${env}-${ISname}" ;
	doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -e IS-${env}-${ISname} -o ComIbmJVMManager -n jvmSystemProperty -v\"-Dlog4j.configurationFile=/var/iib/${env}jumbo/config/eip-${ISname}-log4j2.xml -Deip.config=/var/iib/${env}jumbo/config/eip-config.xml\"" ;
	doMqsiExec "${MQSI_BIN_LOC}/mqsireportproperties ${INTEGRATION_NODE_NAME} -e IS-${env}-${ISname} -o ComIbmJVMManager -r" ;
done

		
######################################################################
# option 2 ips from different network
# each node has it's own ips but same port
######################################################################
#Set HTTP IP and Port for Node level
doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} \
	-b httplistener -o HTTPConnector -n address -v ${INTEGRATION_NODE_IP}"
doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} \
	-b httplistener -o HTTPConnector -n port -v ${INTEGRATION_NODE_PORT}"

#disable and enable soap node listener. forces integration server to use integration server level http listener
doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -b httplistener -o HTTPListener -n startListener -v false"
doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} -e IS-${env}-vwa -o ExecutionGroup -n soapNodesUseEmbeddedListener,httpNodesUseEmbeddedListener -v true,true"
		
######################################################################
#Set HTTP IP and Port for Integration Server level SOAP listeners
######################################################################
# Integration Server "vwa" on Jumbo IIB
doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} \
	-e IS-${env}-vwa \
        -o HTTPConnector -n address,explicitlySetPortNumber -v ${INTEGRATION_NODE_IP},${INTEGRATION_SERVER_COMMON_PORT}"

# -----------------------------------------------------------------------#
# Enable SSL on the webadmin port
# First create a key store and key/certificate pair
# The setup will use autosigning information from the MQ config.
# Then set up the webadmin properties to use it all
e=${HOSTNAME:1:1}
E=${e^^}
source ${MQSIGNINFO}
MQAUTOSIGN=${MQAUTOSIGNLIST[$E]}
MQCASERVER=${MQCASERVERLIST[$E]}
MQCACREDFILE=${CONFIGDIR}/${MQCACREDFILELIST[$E]}
MQCAUSERNAME=${MQCAUSERNAMELIST[$E]}

# Only do the SSL work if the ssl directory doesn't already exist. If the
# directory already exists, we reuse whatever is there.
IIBSSLDIR=${INTEGRATION_NODE_WORK_PATH}/ssl
if [ ! -d $IIBSSLDIR ] ; then
	mkdir ${IIBSSLDIR}
	chown ${IIB_ADMIN_USER}:mqbrkrs ${IIBSSLDIR}
	chmod 700 ${IIBSSLDIR}
	# Create strong random passphrase
	runmqakm -random -create -length 125 -strong \
			| tr -d "'" | tr -d '\\\$\%\`\,\~\&\@\!\|\\[\]\(\)\{\}\;" ' \
			| cut -c 2-65 \
			> ${IIBSSLDIR}/webadmin.passwd
	# Create the keystore file
	runmqckm -keydb -create -db ${IIBSSLDIR}/webadmin.jks \
			-pw "`cat ${IIBSSLDIR}/webadmin.passwd`" \
			-type jks
	# Set ownership and tightest available security
	chown ${IIB_ADMIN_USER}:mqbrkrs ${IIBSSLDIR}/*
	chmod 600 ${IIBSSLDIR}/*
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
			runmqckm -cert -add -db ${IIBSSLDIR}/webadmin.jks \
				-type jks \
				-pw "`cat ${IIBSSLDIR}/webadmin.passwd`" \
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
	runmqckm -certreq -create -db ${IIBSSLDIR}/webadmin.jks \
		-type jks \
		-pw "`cat ${IIBSSLDIR}/webadmin.passwd`" \
		-label ${INTEGRATION_NODE_NAME} \
			-dn "CN=${INTEGRATION_NODE_IP},OU=${ENV}Jumbo,OU=IBM IIB,O=ITSS,L=Melbourne,ST=VIC,C=AU" \
		-file ${IIBSSLDIR}/${INTEGRATION_NODE_IP}.req \
			-sig_alg SHA256_WITH_RSA -size 2048
	res=$?
	if [ $res -eq 0 ] ; then
		# Reset CSR file ownership
		chown ${IIB_ADMIN_USER}:mqbrkrs ${IIBSSLDIR}/${INTEGRATION_NODE_IP}.req
		chmod 600 ${IIBSSLDIR}/${INTEGRATION_NODE_IP}.req
		echo
		echo "Certificate signing request created:"
		if [ "$MQAUTOSIGN" == "yes" ] ; then
			# Sign the certificate automatically using ssh to run
			# the 'sign' command
			cat $IIBSSLDIR/${INTEGRATION_NODE_IP}.req | \
				( ssh $MQCAUSERNAME@$MQCASERVER -q -i $MQCACREDFILE \
					"vwaCA/sign ${INTEGRATION_NODE_IP} -q" ) \
				> $IIBSSLDIR/${INTEGRATION_NODE_IP}.cer
			res=$?
			if [ $res -ne 0 ] ; then
				echo "Unable to autosign certificate"
				echo "Giving up. You will need to fix the problem,"
				echo "delete the integration node and restart"
				exit 1
			fi
			runmqckm -cert -receive -db ${IIBSSLDIR}/webadmin.jks \
				-type jks \
				-pw "`cat ${IIBSSLDIR}/webadmin.passwd`" \
				-file $IIBSSLDIR/${INTEGRATION_NODE_IP}.cer
			res=$?
			if [ $res -ne 0 ] ; then
				echo "Unable to receive certificate"
				echo "Giving up. You will need to fix the problem,"
				echo "delete the integration node and restart"
				exit 1
			else
				echo "autosigned certificate received"
				CREDFILENAME=$(basename $MQCACREDFILE)
				cp $MQCACREDFILE $IIBSSLDIR/$CREDFILENAME
				chown ${IIB_ADMIN_USER}:mqbrkrs $IIBSSLDIR/$CREDFILENAME
				chmod 600 $IIBSSLDIR/$CREDFILENAME
				cat <<-CACREDINFO > $IIBSSLDIR/ca.properties
	CAUSER=$MQCAUSERNAME
	CASERVER=$MQCASERVER
	CACREDS=$IIBSSLDIR/$CREDFILENAME
	CACREDINFO
				chown ${IIB_ADMIN_USER}:mqbrkrs $IIBSSLDIR/ca.properties
				chmod 600 $IIBSSLDIR/ca.properties
			fi
		else
			echo "Send file $IIBSSLDIR/${INTEGRATION_NODE_IP}.req to be signed by your CA"
		fi
		echo
	else
		echo "Failed to create certificate signing request."
			echo "Giving up. You will need to delete the integration node,"
			echo "fix the problem and start again."
			exit 1
	fi
fi

#Set webadmin to use SSL
doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} \
        -b webadmin -o server -n enableSSL -v true"

#Enable the webadmin service
doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} \
        -b webadmin -o server -n enabled -v true"

#Set HTTPS IP and Port for webadmin
doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} \
	-b webadmin -o HTTPSConnector -n address -v ${INTEGRATION_NODE_IP}"
doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} \
	-b webadmin -o HTTPSConnector -n port -v ${INTEGRATION_ADMIN_PORT}"

#Set keystore info for webadmin
doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} \
	-b webadmin -o HTTPSConnector \
	-n keystoreFile \
	-v ${IIBSSLDIR}/webadmin.jks"
doMqsiExec "${MQSI_BIN_LOC}/mqsichangeproperties ${INTEGRATION_NODE_NAME} \
	-b webadmin -o HTTPSConnector \
	-n keystorePass \
	-v '\"$(cat ${IIBSSLDIR}/webadmin.passwd)\"'"


# -----------------------------------------------------------------------#
# set /var/mqsi/<env>jumbo just created with creating message broker workpath
# if not, mqm or IBExplore will not able to access Integration Node
#
# TODO : make sure of this.
# drwxrws---. 6 iibadmin_sit mqbrkrs    4096 Jan 27 23:29 sit
# to
# drwxrws---. 6 mqm mqbrkrs    4096 Jan 27 23:29 sit
#

chown -R ${IIB_ADMIN_USER}:mqbrkrs /var/mqsi
chmod -R ug+rwX /var/mqsi
		
chmod g+s /var/mqsi
find /var/mqsi -type f -exec chmod g+s {} \;


#TODO Verify
doMqsiExec "${MQSI_BIN_LOC}/mqsireportbroker ${INTEGRATION_NODE_NAME}"
#doMqsiExec "${MQSI_BIN_LOC}/mqsireportproperties ${INTEGRATION_NODE_NAME} -c ODBCProviders -o ${TPC2_ODBC_PROVIDER_NAME} -r"
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
# Create IIB webadmin default local user
#
doMqsiExec "${MQSI_BIN_LOC}/mqsiwebuseradmin ${INTEGRATION_NODE_NAME} -c -u deploy -r iibadmin -a ${INTEGRATION_DEPLOY_PWD}"

# -----------------------------------------------------------------------#
# Restart to activate the new configuration
#
echo "restart integration node"
doMqsiExec "${MQSI_BIN_LOC}/mqsistop ${INTEGRATION_NODE_NAME}"

#Activate authentication for webadmin
doMqsiExec "${MQSI_BIN_LOC}/mqsichangeauthmode ${INTEGRATION_NODE_NAME} \
	-s active -m file"

doMqsiExec "${MQSI_BIN_LOC}/mqsistart ${INTEGRATION_NODE_NAME}"

# -----------------------------------------------------------------------#
# Create init.d script and rc?.d auto start/stop
#

ln -s /etc/init.d/iib.init /etc/init.d/iib_${INTEGRATION_NODE_NAME}
chkconfig --add iib_${INTEGRATION_NODE_NAME}
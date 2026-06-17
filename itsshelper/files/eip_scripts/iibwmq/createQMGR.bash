#!/bin/bash

# QMgr creation script for MQ v8.
# Finds installation via /etc/opt/mqm/mqinst.ini
# Sets environment using the discovered installation directory

MQMUSR="mqm"
QMGR_EXISTS=12

usage()
{
  echo "USAGE: $(basename $0) env props_file"
}
  

doExec()
{
     cmd=$1
     # echo "simulating: $cmd"
     # pwd
     echo "performing: $cmd" >&2
     su $MQMUSR -c "$cmd"
     if [ $? -ne 0 ]; then
       echo "ERROR executing command: ${cmd}" >&2
       echo "Exiting script..." >&2
       exit 1
     fi
}

qmgrExists()
{
  dspmq -m "$QMGRNAME" > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "true"
  else
    echo "false"
  fi
}

qmgrStatus()
{
  dspmq -m ${QMGRNAME} | sed 's/.*STATUS(\(.*\))/\1/'
}

if [ $# -ne 2 ];then
  usage
  exit 1
fi

if [ $(whoami) != "root" ];then
  echo "ERROR: script must be run as root"
  exit 1
fi

# Collect command line arguments
export ENV=$1
export env=${ENV,,} # lower case
export UENV=${env^^} # upper case
export PROPS=$2

# Find a working MQ installation location
MQBASE=$(cat /etc/opt/mqm/mqinst.ini | awk -F "=" "/FilePath/ {print \$2}")
for base in $MQBASE ; do
	if [ -x $base/bin/setmqenv ] ; then
		MQBASE=$base
		break
	fi
done

# Set the MQ environment to the requested environment name
source $MQBASE/bin/setmqenv -p /opt/ibm/${env}/mqm
if [ $? -ne 0 ] ; then
  echo "Failed to set MQ environment. Does $env MQ installation exist?"
  exit 1
fi

# Source the common build info
ROOTDIR=`dirname $0`            # get dirname to this script

# Import Subroutines
#
source ${ROOTDIR}/build_common.bash
initVars MQM create

echo CONFIGDIR=$CONFIGDIR
if [ ! -f ${CONFIGDIR}/$PROPS.prop ] ; then
  echo "ERROR: props file not found: $PROPS"
  echo "Locate props file in properties directory, with .prop suffix"
  echo "Available props files are:"
  (cd ${CONFIGDIR}/; ls *.prop | while read a ; do basename $a .prop ; done)
  exit 1
fi
PROPS=${CONFIGDIR}/$PROPS.prop
source $PROPS

# Validate Repository queue manager
# It must not be blank
# It must not be the current (new) queue manager
# It must start with the same 4 characters (cluster and environment)
# The fifth character must be F
if [ -z "$REPOQM" ] ; then
	echo "Invalid mqrepo.prop. No repository defined for ${QMGRNAME}"
	exit 1
fi
if [ "$QMGRNAME" == "$REPOQM" ] ; then
	echo "Invalid mqrepo.prop. $REPOQM cannot be the created qmgr $QMGRNAME"
	exit 1
fi
if [ "${QMGRNAME:0:4}" != "${REPOQM:0:4}" ] ; then
	echo "Invalid Repository QM name $REPOQM defined in mqrepo.prop"
	echo "It must be in the same cluster and environment as the new QM"
	exit 1
fi
if [ "${REPOQM:4:1}" != "F" ] ; then
	echo "Invalid Repository QM name $REPOQM defined in mqrepo.prop"
	echo "Not a full repository style name"
	exit 1
fi
# Export the REPOQM variable for user in translate.bash
export REPOQM

TEMPLATE=$QMGR_TEMPLATE
if [ -z ${TEMPLATE} ] ; then
  echo "ERROR: variable \$QMGR_TEMPLATE not defined in ${PROPS}"
  exit 1
fi
MAPPING=${TEMPLATE}.map

# -----------------------------------------------------------------------#
# check files
#
for f in $TEMPLATE $PROPS $MAPPING $REPOLIST ; do
  if [ ! -f $f ]; then
    echo "ERROR: file not found: $f"
    exit 1
  fi
done

# -----------------------------------------------------------------------#
# check host name resolution
#
getent hosts $QMHOST > /dev/null
if [ $? -ne 0 ] ; then
	echo "Could not resolve QMHOST $QMHOST"
	exit 1
fi
getent hosts $REPOHOST > /dev/null
if [ $? -ne 0 ] ; then
	echo "Could not resolve REPOHOST $REPOHOST"
	exit 1
fi

# -----------------------------------------------------------------------#
# create QUEUE MANAGER
#
if [ $(qmgrExists) == "false"  ]; then
  doExec "crtmqm -c \"$QMTYPE QMgr for $env environment\" -lc -lf 4096 -lp 10 -ls 4 -u SYSTEM.DEAD.LETTER.QUEUE ${QMGRNAME}"
else
  echo "${QMGRNAME} already exists..."
fi

# -----------------------------------------------------------------------#
# Set queue manager to command level 801 to enable LDAP
#

if [ "$(qmgrStatus)" != "Running" ]; then
  doExec "strmqm -e CMDLEVEL=801 ${QMGRNAME}"
fi

# -----------------------------------------------------------------------#
# Find QM directory. Get prefix and dirname from dspmqinf
#
QMGR_PREFIX_DIR=$(doExec "dspmqinf -o stanza $QMGRNAME" | awk -F "=" "/Prefix/ {print \$2}")
QMGR_DIRNAME=$(doExec "dspmqinf -o stanza $QMGRNAME" | awk -F "=" "/Directory/ {print \$2}")
QMGR_DIR=${QMGR_PREFIX_DIR}/qmgrs/${QMGR_DIRNAME}

# -----------------------------------------------------------------------#
# Set Security Policy mode to user (default is group)
#

# Use awk to add the SecurityPolicy line to the AuthorizationService stanza
cat $QMGR_DIR/qm.ini | awk "BEGIN {doit=0};/Name=AuthorizationService/ {doit=1};/SecurityPolicy/ {doit=0};/^ServiceComponent:/ {if (doit==1) {print \"   SecurityPolicy=user\";doit=0}}; {print}" > $QMGR_DIR/qm.ini.temp
if [ $? -eq 0 ] ; then
	mv $QMGR_DIR/qm.ini.temp $QMGR_DIR/qm.ini
	chown mqm:mqm $QMGR_DIR/qm.ini
else
	rm -f $QMGR_DIR/qm.ini.temp
fi

# -----------------------------------------------------------------------#
# Set Channels stanza if it doesn't already exist
#
grep -E -q "^Channels:" $QMGR_DIR/qm.ini
if [ $? -eq 0 ] ; then
	echo "Channels stanza already exists."
	echo "Adjust if necessary"
else
	cat <<-'CHANNELS.INI' >> $QMGR_DIR/qm.ini
	Channels:
	   MaxChannels=1000
	   MaxActiveChannels=1000
	   AdoptNewMCA=ALL
	   AdoptNewMCATimeout=60
	   AdoptNewMCACheck=QM,NAME
	CHANNELS.INI
	echo "Channels stanza set for $QMGRNAME"
fi

# -----------------------------------------------------------------------#
# Set Security stanza if it doesn't already exist
#

grep -E -q "^Security:" $QMGR_DIR/qm.ini
if [ $? -eq 0 ] ; then
	echo "Security stanza already exists."
	echo "Adjust if necessary"
else
	cat <<-'SECURITY.INI' >> $QMGR_DIR/qm.ini
	Security:
	   ClusterQueueAccessControl=RQMName
	SECURITY.INI
	echo "Security stanza set for $QMGRNAME"
fi

# -----------------------------------------------------------------------#
# Set SSL stanza if it doesn't already exist
#

grep -E -q "^SSL:" $QMGR_DIR/qm.ini
if [ $? -eq 0 ] ; then
	echo "SSL stanza already exists."
	echo "Adjust if necessary"
else
	cat <<-'SSL.INI' >> $QMGR_DIR/qm.ini
	SSL:
	   CDPCheckExtensions=NO
	   OCSPCheckExtensions=NO
	   OCSPAuthentication=OPTIONAL
	SSL.INI
	echo "Security stanza set for $QMGRNAME"
fi

# -----------------------------------------------------------------------#
# Create symlink in init.d for controlling queue manager as a service
#
echo "Setting up service mq_${QMGRNAME} to manage queue manager"
ln -s /etc/init.d/mqm.init /etc/init.d/mq_${QMGRNAME}

# -----------------------------------------------------------------------#
# Create rc?.d entries to automatically control queue manager at startup
# and shutdown of server
#

echo "Setting up auto start/stop service for ${QMGRNAME}"
chkconfig --add mq_${QMGRNAME}

# -----------------------------------------------------------------------#
# Create key store and populate with trusted certificate
#
# Ensure that any key.* files are deleted
rm -f $QMGR_DIR/ssl/key.*
# Ensure ssl directory has tightest possible security
chmod 700 $QMGR_DIR/ssl
# Create strong random passphrase
runmqakm -random -create -length 125 -strong \
        | tr -d "'" | tr -d '\\\$\%\`\~\&\@\!\|\\[\]\(\)\{\}\;" ' \
        | cut -c 2-65 \
        > $QMGR_DIR/ssl/key.passwd
# Create the keystore file
runmqakm -fips -keydb -create -db $QMGR_DIR/ssl/key.kdb \
        -pw "`cat $QMGR_DIR/ssl/key.passwd`" \
        -type cms -stash -empty
# Set ownership and tightest available security
chown mqm:mqm $QMGR_DIR/ssl/key.*
chmod 600 $QMGR_DIR/ssl/key.*
# Add the VWA certificates
# The arrays are declared and initialised in mqcacertlist.properties
# This is included from the .prop file
# The arrays are CA_Certs and CA_Labels
for (( i=0 ; i<${#CA_Certs[*]} ; i++ )) ; do
        if [ ! -f ${CA_Certs[i]} ] ; then
                echo "Certificate file ${CA_Certs[i]} missing"
                echo "Check that ../properties directory is correctly built"
        else
                runmqakm -fips -cert -add -db $QMGR_DIR/ssl/key.kdb -stashed \
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
qmgrname=${QMGRNAME,,} # lower case
MQSSLDIR=$QMGR_DIR/ssl
runmqakm -fips -certreq -create -db $QMGR_DIR/ssl/key.kdb -stashed \
	-label ibmwebspheremq${qmgrname} \
	-dn "CN=${QMGRNAME},OU=/${UENV}/,OU=IBM MQ QMgr,O=ITSS,L=Melbourne,ST=VIC,C=AU" \
	-target $QMGR_DIR/ssl/${qmgrname}.req \
	-sig_alg sha256 -size 2048
res=$?
if [ $res -eq 0 ] ; then
	# Reset CSR file ownership
	chown mqm:mqm $MQSSLDIR/${qmgrname}.req
	chmod 600 $MQSSLDIR/${qmgrname}.req
	echo
	echo "Certificate signing request created:"
	if [ "$MQAUTOSIGN" == "yes" ] ; then
		# Sign the certificate automatically using ssh to run
		# the 'sign' command
		cat $MQSSLDIR/${qmgrname}.req | \
			( ssh $MQCAUSERNAME@$MQCASERVER -oStrictHostKeyChecking=no -q -i $MQCACREDFILE \
				"vwaCA/sign ${qmgrname} -q" ) \
			| ${ROOTDIR}/createQMGRCert.bash $1 $2
		res=$?
		if [ $res -ne 0 ] ; then
			echo "Unable to populate autosigned certificate into key store"
			echo "Giving up. You will need to fix the problem,"
			echo "delete the queue manager and restart"
			exit 1
		else
			echo "autosigned certificate received"
			CREDFILENAME=$(basename $MQCACREDFILE)
			cp $MQCACREDFILE $MQSSLDIR/$CREDFILENAME
			chown mqm:mqm $MQSSLDIR/$CREDFILENAME
			chmod 600 $MQSSLDIR/$CREDFILENAME
			cat <<CACREDINFO > $MQSSLDIR/ca.properties
CAUSER=$MQCAUSERNAME
CASERVER=$MQCASERVER
CACREDS=$MQSSLDIR/$CREDFILENAME
CACREDINFO
			chown mqm:mqm $MQSSLDIR/ca.properties
			chmod 600 $MQSSLDIR/ca.properties
		fi
	else
		echo "Send file $MQSSLDIR/${qmgrname}.req to be signed by your CA"
	fi
	echo
else
	echo "Failed to create certificate signing request."
	echo "Giving up. You will need to use deleteQMGR.bash"
	echo "to delete the queue manager, fix the problem and start again."
	exit 1
fi

# -----------------------------------------------------------------------#
# start QUEUE MANAGER
#
if [ "$(qmgrStatus)" != "Running" ]; then
  doExec "strmqm ${QMGRNAME}"
else
  echo "${QMGRNAME} already started..."
fi

# -----------------------------------------------------------------------#
# create QUEUE MANAGER OBJECTS CONFIGURATION FILE
#
echo "Generating mqsc file from template..."
OUTPUT=$(dirname ${PROPS})/${env}_${QMTYPE}.mqsc
touch ${OUTPUT}
chmod 644 $OUTPUT
${ROOTDIR}/translate.bash ${TEMPLATE} ${PROPS} ${MAPPING} ${OUTPUT}
if [ $? -ne 0 ] ; then
	echo "Error: Translation of template failed. Giving up"
	exit 1
fi

# -----------------------------------------------------------------------#
# create QUEUE MANAGER OBJECTS 
#
echo "Creating MQ object using  mqsc file..."
echo "See /tmp/${QMGRNAME}.mqsc.log for detailed runmqsc output"
doExec "runmqsc ${QMGRNAME} < ${OUTPUT}" > /tmp/${QMGRNAME}.mqsc.log

echo "Queue Manager creation for ${QMGRNAME} completed."

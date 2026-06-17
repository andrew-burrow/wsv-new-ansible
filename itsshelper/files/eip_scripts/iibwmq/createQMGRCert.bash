#!/bin/bash
# Receive the qmgr certificate from the terminal 
# Create the .cer file in the ssl directory for the queue manager
# Receive the certificate into the CMS key store

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
ENV=$1
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
source ${ROOTDIR}/build_common.bash
initVars MQM create

if [ ! -f ${CONFIGDIR}/$PROPS.prop ] ; then
  echo "ERROR: props file not found: $PROPS"
  echo "Locate props file in properties directory, with .prop suffix"
  echo "Available props files are:"
  (cd ${CONFIGDIR}/; ls *.prop | while read a ; do basename $a .prop ; done)
  exit 1
fi
PROPS=${CONFIGDIR}/$PROPS.prop
source $PROPS

TEMPLATE=$QMGR_TEMPLATE
if [ -z ${TEMPLATE} ] ; then
  echo "ERROR: variable \$QMGR_TEMPLATE not defined in ${PROPS}"
  exit 1
fi
MAPPING=${TEMPLATE}.map

# -----------------------------------------------------------------------#
# check files
#
for f in $TEMPLATE $PROPS $MAPPING; do
  if [ ! -f $f ]; then
    echo "ERROR: file not found: $f"
    exit 1
  fi
done

# -----------------------------------------------------------------------#
# Find QM directory. Get prefix and dirname from dspmqinf
#
QMGR_PREFIX_DIR=$(doExec "dspmqinf -o stanza $QMGRNAME" | awk -F "=" "/Prefix/ {print \$2}")
QMGR_DIRNAME=$(doExec "dspmqinf -o stanza $QMGRNAME" | awk -F "=" "/Directory/ {print \$2}")
QMGR_DIR=${QMGR_PREFIX_DIR}/qmgrs/${QMGR_DIRNAME}

# -----------------------------------------------------------------------#
# Receive the certificate from the terminal. 
#
qmgrname=${QMGRNAME,,} # lower case
echo "Paste the certificate PEM content below, then <ctrl-D> after the last line"
cat > $QMGR_DIR/ssl/${qmgrname}.cer
# Ensure file has tightest possible security
chown mqm:mqm $QMGR_DIR/ssl/${qmgrname}.cer
chmod 600 $QMGR_DIR/ssl/${qmgrname}.cer
# Receive the signed certificate
runmqakm -fips -cert -receive -db $QMGR_DIR/ssl/key.kdb -stashed \
         -file $QMGR_DIR/ssl/${qmgrname}.cer


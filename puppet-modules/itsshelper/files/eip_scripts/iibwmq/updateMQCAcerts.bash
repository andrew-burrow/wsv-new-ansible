#!/bin/bash
# check the MQ trust store against the configuration files
# if any CA certs are missing, add them
# if any CA certs are not in the configuration files, delete them

# Takes parameters: env props_file

# Like everything else in the script package, it runs only as root
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
source $MQBASE/bin/setmqenv -p /opt/${env}/mqm
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

# -----------------------------------------------------------------------#
# Find QM directory. Get prefix and dirname from dspmqinf
#
QMGR_PREFIX_DIR=$(doExec "dspmqinf -o stanza $QMGRNAME" | awk -F "=" "/Prefix/ {print \$2}")
QMGR_DIRNAME=$(doExec "dspmqinf -o stanza $QMGRNAME" | awk -F "=" "/Directory/ {print \$2}")
QMGR_DIR=${QMGR_PREFIX_DIR}/qmgrs/${QMGR_DIRNAME}

# Check that the keystore exists before doing anything
if [ ! -f $QMGR_DIR/ssl/key.kdb ] ; then
	echo "Key store $QMGR_DIR/ssl/key.kdb does not exist. Giving up."
	exit 10
fi

# Collect CA certificate serial numbers from the MQ key database
# Start by getting the labels, then get the serial number of each cert
# Put the labels and serial numbers into arrays
declare -a mqCAlabelList
CACount=0
while read CALabel ; do
	mqCAlabelList[$CACount]="$CALabel" ;
	(( CACount++ )) ;
done < <( runmqakm -fips -cert -list -db $QMGR_DIR/ssl/key.kdb -stashed \
	| awk -F '"' "/^\!/ {print \$2}" )

declare -a mqCAserialList
for (( i=0 ; i<CACount ; i++ )) ; do
	mqCAserialList[i]=$(runmqakm -fips -cert -details -db $QMGR_DIR/ssl/key.kdb -stashed \
		-label "${mqCAlabelList[i]}" \
		| awk "/Serial/ {print \$3}" \
		| sed "s/^0*//g")
done

# echo "CA List from MQ key database ${mqCAlabelList[*]}"
# echo "CA Serials from MQ key database ${mqCAserialList[*]}"

# Use openssl to get the serial numbers of the CA certificates 
# The list of certificates is in the CA_Certs array

declare -a stdCAserialList
CACount=0
for fnm in ${CA_Certs[*]} ; do
	if [ -f $fnm ] ; then
		serialnum=$(openssl x509 -in $fnm -text \
        	| awk "/Serial/ {if ( \$4 != \"\" ) { print \$4 } else { getline ; print } }" \
		    | sed -e "s/[()]//g" -e "s/^0x//g" -e "s/://g" -e "s/[[:blank:]]//g" -e "s/^0*//g" ) ;
		stdCAserialList[$CACount]=$serialnum ;
		(( CACount++ )) ;
	else
		echo "Invalid CA file name: $fnm does not exist. Ignoring file."
	fi
done

# echo "CA List from config files ${CA_Certs[*]}"
# echo "CA Series from config files ${stdCAserialList[*]}"

# Build an array of the cert serials in the key store. 
# Check each serial from the CA certs
# If any are missing, add them to the key store

declare -A mqSerials
for serial in "${mqCAserialList[@]}" ; do
	# echo "Adding $serial to mqSerials associative array"
	mqSerials[$serial]="1"
done

CACount=0
for serial in "${stdCAserialList[@]}" ; do
	# echo "Looking at serial $serial"
	if [ -z "${mqSerials[$serial]}" ] ; then
		echo "Adding CA cert \"${CA_Labels[CACount]}\" to key store $QMGR_DIR/ssl/key.kdb"
		runmqakm -fips -cert -add -db $QMGR_DIR/ssl/key.kdb -stashed -label "${CA_Labels[CACount]}" -file ${CA_Certs[CACount]}
	fi
	(( CACount++ ))
done

# Build an array of the serial numbers in the config file
# If any of the MQ serial numbers are not in the config file list, delete them from the key store

declare -A CASerials
for serial in "${stdCAserialList[@]}" ; do
	# echo "Adding $serial to CASerials associative array"
    CASerials[$serial]="1"
done

CACount=0
for serial in "${mqCAserialList[@]}" ; do
	# echo "Looking at serial $serial"
    if [ -z "${CASerials[$serial]}" ] ; then
		echo "Removing CA cert \"${mqCAlabelList[CACount]}\" from key store $QMGR_DIR/ssl/key.kdb" ;
        runmqakm -fips -cert -delete -db $QMGR_DIR/ssl/key.kdb -stashed -label "${mqCAlabelList[CACount]}" ;
    fi
    (( CACount++ ))
done


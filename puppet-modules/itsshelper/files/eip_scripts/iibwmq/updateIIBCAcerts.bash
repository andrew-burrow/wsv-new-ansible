#!/bin/bash
# check the IIB webadmin trust store against the configuration files
# if any CA certs are missing, add them
# if any CA certs are not in the configuration files, delete them

# Takes parameters: env [jumbo]

# Like everything else in the script package, it runs only as root
# Finds installation via /etc/opt/mqm/mqinst.ini
# Sets environment using the discovered installation directory

MQMUSR="mqm"
QMGR_EXISTS=12

usage()
{
    echo "USAGE: $(basename $0) env [jumbo]"
}

if [ $# -lt 1 ] ; then
    usage
    exit 1
elif [ $# -gt 2 ] ; then
    usage
    exit 1
elif [ $# -eq 2 ] ; then
    if [ "$2" != "jumbo" ] ; then
        usage
        exit 1
    fi
fi

if [ $(whoami) != "root" ] ; then
    echo "ERROR: script must be run as root"
    exit 1
fi

# Collect command line arguments
export ENV=$1
export env=${ENV,,} # lower case
export UENV=${env^^} # upper case
export JUMBO=$2

# Find a working MQ installation location
# We are going to use the gskit from MQ to handle to jks file
MQBASE=$(cat /etc/opt/mqm/mqinst.ini | awk -F "=" "/FilePath/ {print \$2}")
for base in $MQBASE ; do
    if [ -x $base/bin/setmqenv ] ; then
        MQBASE=$base
        break
    fi
done

# Set the MQ environment to the requested environment name
source $MQBASE/bin/setmqenv -p /opt/${env}${JUMBO}/mqm
if [ $? -ne 0 ] ; then
    echo "Failed to set MQ environment. Does ${env}${JUMBO} MQ installation exist?"
    exit 1
fi

# Source the common build info
ROOTDIR=`dirname $0`            # get dirname to this script

# Import Subroutines
#
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

# echo CONFIGDIR=$CONFIGDIR

KEYSTOREDIR=/var/mqsi/${env}${JUMBO}/ssl
KEYSTORE=${KEYSTOREDIR}/webadmin.jks
KEYSTOREPASS=$(cat ${KEYSTOREDIR}/webadmin.passwd)
# Check that the keystore exists before doing anything
if [ ! -f ${KEYSTORE} ] ; then
    echo "Key store ${KEYSTORE} does not exist. Giving up."
    exit 10
fi

# source mqsiprofile so that we can use keytool from the JRE
. /opt/${env}${JUMBO}/iib/server/bin/mqsiprofile

# Collect CA certificate serial numbers from the IIB key database
# Extract the label and serial number of each cert
# with "Entry type" of trustedCertEntry
# Put the labels and serial numbers into arrays
declare -a iibCAlabelList
declare -a iibCAserialList

CACount=0
while read CASerial CALabel ; do
    iibCAlabelList[$CACount]="$CALabel" ;
    iibCAserialList[$CACount]="$CASerial" ;
    (( CACount++ )) ;
done < <( keytool -list -keystore ${KEYSTORE} \
        -storetype jks -storepass ${KEYSTOREPASS} -v \
        | awk -v QT='"' "/^Entry type:/ {ET=\$3};/^Alias name:/ {\$1=\" \";\$2=\" \";sub(/^[[:blank:]]*/,\"\",\$0);sub(/^0*/,\"\");LABEL=\$0};/^Serial number:/ {\$1=\"\";\$2=\"\";SERIAL=\$0;if (ET == \"trustedCertEntry\") {print SERIAL , LABEL}}" )

# echo "CA certs from IIB trust store ${iibCAlabelList[*]}"
# echo "CA serials from IIB trust store ${iibCAserialList[*]}"

# Set up environment needed for CA processing
e=${HOSTNAME:1:1}
E=${e^^}
source ${MQCACERTS}

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

# echo "CA certs from config ${CA_Certs[*]}"
# echo "CA serials from config ${stdCAserialList[*]}"

# Build an array of the cert serials in the key store.
# Check each serial from the CA certs
# If any are missing, add them to the key store

declare -A iibSerials
for serial in "${iibCAserialList[@]}" ; do
    # echo "Adding $serial to iibSerials associative array"
    iibSerials[$serial]="1"
done

CACount=0
for serial in "${stdCAserialList[@]}" ; do
    # echo "Looking at serial $serial"
    if [ -z "${iibSerials[$serial]}" ] ; then
        echo "Adding CA cert \"${CA_Labels[CACount]}\" to key store ${KEYSTORE}"
        runmqckm -cert -add -db ${KEYSTORE} -type jks -pw ${KEYSTOREPASS} \
            -label "${CA_Labels[CACount]}" -file ${CA_Certs[CACount]}
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
for serial in "${iibCAserialList[@]}" ; do
    # echo "Looking at serial $serial"
    if [ -z "${CASerials[$serial]}" ] ; then
        echo "Removing CA cert \"${iibCAlabelList[CACount]}\" from key store ${KEYSTORE}" ;
        runmqckm -cert -delete -db ${KEYSTORE} -type jks -pw ${KEYSTOREPASS} \
            -label "${iibCAlabelList[CACount]}" ;
    fi
    (( CACount++ ))
done

#!/bin/bash

#
# program:	uninstall_MQM.bash
# author:	Boris Carli, WorkSafe
# date:		Oct 31 2012
# pupose:	Uninstalls WebSphere MQ Series v8 Server on RHEL6
#


# source the common vars script
#
PROG=`basename $0 .bash`        # get short name of script
ROOTDIR=`dirname $0`            # get dirname to this script

if [ -z "$1" ]
        then
                echo "ERROR : No argument for ENV level supplied- no uninstall will be performed."
		exit 1
        else
                echo "INFO : Performing uninstallation for ${1} ENV."
fi

export ENV=$1
export env=${ENV,,} # lower case
export UENV=${env^^} # upper case


# Import Subroutines
#
source ${ROOTDIR}/build_common.bash

# globals for this script
#

# initialise all vars for this product
# to do this determine PRODUCT from _<PRODUCT> name of this script
#
OPERATION=${PROG%_*}                    # determine operation from suffix before 
					#	"_<PRODUCT>" of (symlink)name of this script
PRODUCT=${PROG#*_}                      # get <PRODUCT> after '_' of (symlink)name of this script
initVars $PRODUCT $OPERATION

# main
#
MQMRPMPREFIX="MQSeries"
MQMRPMVERSION=$env

# Set up MQ Environment to allow start/stop
. /opt/${env}/mqm/bin/setmqenv -s

# verify correct state for PRODUCT to perform OPERATION
#
assessBuildState $OPERATION $PRODUCT

# if operation is to uninstall then ensure appopriate services are stopped
#
manageServices $OPERATION $PRODUCT

# proceed with silent (un)install
#
pkgrm $MQMRPMPREFIX $MQMRPMVERSION

# generate or remove start/stop script
#
#manageStartupScript $OPERATION $PRODUCT $INSTALLDIR

# Remove various shared components if there are no other 
# MQ installations still in place.

if [ -z "$(find /opt -name setmqenv)" ] ; then
	# remove mqm.init from /etc/init.d 
	rm -f /etc/init.d/mqm.init

	# remove /var/mqm/utilities directory
	rm -rf /var/mqm/utilities
fi

# print message to manually remove /var/mqm ....
#
log "Please ensure to manually remove the /var/mqm/* Queue Manager artefacts if no longer required - thankyou."

# generate installation target artefact
#
assertBuildTarget $OPERATION $PRODUCT

# finalise logging
#
log "$0 completing"
log " "


WHAT=<<TO_HERE;
  3.3.6.3 Linux

    1. Log in as root.
    2. To find out which packages are installed on your machine, enter the
       following:

         rpm -q -a | grep MQSeries

       For example, if you have a minimum WebSphere MQ installation and SDK
       component, at level 7.0.0.0, this will return:

         MQSeriesRuntime-7.0.0-0
         MQSeriesSDK-7.0.0-0
         MQSeriesServer-7.0.0-0

    3. Now install all available updates for the packages you have on your
       system:

        rpm -ivh MQSeriesRuntime-Uxxxx-7.0.1-0.i386.rpm \
        MQSeriesSDK-Uxxxx-7.0.1-0.i386.rpm              \
        MQSeriesServer-Uxxxx-7.0.1-0.i386.rpm

       Note: You must install all 7.0.1.1 packages that apply to those 7.0.0.0, 
       7.0.0.1,  7.0.0.2 or 7.0.1.0 packages that are currently installed on your system.

    4. Repeat step 2, and you will see that the Runtime, SDK and Server
       packages are now at level 7.0.1.1:

         MQSeriesRuntime-7.0.0-0
         MQSeriesSDK-7.0.0-0
         MQSeriesServer-7.0.0-0
         MQSeriesRuntime-Uxxxxxx-7.0.1-1
         MQSeriesSDK-Uxxxxxx-7.0.1-1
         MQSeriesServer-Uxxxxxx-7.0.1-1
TO_HERE

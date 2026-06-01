#!/bin/bash

#
# program:	uninstall_IIB.bash
# author:	Neil Casey, WorkSafe
# date:		Apr 13 2015
# pupose:	Uninstalls IIB v10 on RHEL6
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
# verify correct state for PRODUCT to perform OPERATION
#
#assessBuildState $OPERATION $PRODUCT

# if operation is to uninstall then ensure appopriate services are stopped
#
#manageServices $OPERATION $PRODUCT

# proceed with silent (un)install
#
if [ ! -d /opt/${ENV}/ ] ; then
	echo "Cannot locate environment ${ENV}"
	exit 1
fi
cd /opt/${ENV}/
# Remove all IIB instances
for dname in $(ls -d iib-*) ; do
	rm -rf $dname
done
# Delete the symbolic link
rm -f iib

# generate or remove start/stop script
#
#manageStartupScript $OPERATION $PRODUCT $INSTALLDIR

# generate installation target artefact
#
assertBuildTarget $OPERATION $PRODUCT

# finalise logging
#
log "$0 completing"
log " "



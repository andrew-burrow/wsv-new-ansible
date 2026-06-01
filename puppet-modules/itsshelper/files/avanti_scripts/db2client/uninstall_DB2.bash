#!/bin/bash

#
# program:	uninstall_DB2.bash
# author:	Boris Carli, WorkSafe
# date:		Nov 15 2012
# pupose:	Install DB2 Client
#

# source the common vars script
#
PROG=`basename $0 .bash`        # get short name of script
ROOTDIR=`dirname $0`            # get dirname to this script
. ${ROOTDIR}/build_common.bash

# Import Subroutines
#
INSTALLDIR_BLD=`dirname $ROOTDIR`       # get build root
. $INSTALLDIR_BLD/db2rtcl/log.bash
. $INSTALLDIR_BLD/db2rtcl/runCheckScripts.bash
. $INSTALLDIR_BLD/db2rtcl/expandIntoDB2.bash
. $INSTALLDIR_BLD/db2rtcl/installDB2.bash
. $INSTALLDIR_BLD/db2rtcl/uninstallDB2.bash
. $INSTALLDIR_BLD/db2rtcl/initVars.bash
. $INSTALLDIR_BLD/db2rtcl/assessBuildState.bash
. $INSTALLDIR_BLD/db2rtcl/assertBuildTarget.bash
. $INSTALLDIR_BLD/db2rtcl/createResponseFile.bash

# setup vars for this product
#
OPERATION=${PROG%_*}		# determine operation from suffix before 
				#   "_<PRODUCT>" of (symlink)name of this script
PRODUCT=${PROG#*_}		# get <PRODUCT> after '_' of (symlink)name of this script
initVars $PRODUCT $OPERATION

# verify correct state for PRODUCT to perform OPERATION
#
assessBuildState $OPERATION $PRODUCT

# before proceeding with install run all relevant check scripts
# for this products
#
runCheckScripts $PRODUCT

# verify instance user
#
try "grep ${DB2INSTANCE} /etc/passwd"
DB2USER=`su - ${DB2INSTANCE} -c "id"`

# proceed with silent uninstall
#
uninstallDB2 $OPERATION $PRODUCT

# generate installation target artefact
#
assertBuildTarget $OPERATION $PRODUCT

# finalise logging
#
echo "$0 completing"
log "$0 completing"
log " "


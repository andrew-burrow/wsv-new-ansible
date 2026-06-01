#!/bin/bash

if [ -z "$1" ] ; then
	echo "ERROR : No argument for ENV level supplied- installation abandoned."
	echo "usage: $0 <env>"
	exit 1
else
	echo "INFO : Performing installation for ${1} ENV."
fi

export ENV=$1
export env=${ENV,,} # lower case

# source the common vars script
#
PROG=`basename $0 .bash`        # get short name of script
ROOTDIR=`dirname $0`            # get dirname to this script

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

# #####################################################################################################
#         verification area

# ------------------------------------------------------
# BRIAN : need iibadmin users for 
# This is temporary. To fit into MQ security configuration
# the iibadmin user on each system must be an eDirectory user

# $ROOTDIR/create_iibadmin_user.bash $1
# ------------------------------------------------------

# verify correct state for PRODUCT to perform OPERATION
#
assessBuildState $OPERATION $PRODUCT

# before proceeding with install run all relevant check scripts
# for this products
#
#runCheckScripts $PRODUCT

# filesystem availability / space check
#
#checkFS $INSTALLFS $INSTALLFSSIZE
#try "du -sh $REPO_ROOT"

# if operation is to uninstall then ensure appopriate services are stopped
#
#manageServices $OPERATION $PRODUCT
# #####################################################################################################


# proceed with silent (un)install
#
if [ $OPERATION != "uninstall" ] ; then
	
	if [ ! -d "$REPOSITORYDIR" ] ; then	# repository not mounted?
		log "$0 - error: REPOSITORYDIR \"$REPOSITORYDIR\" not visible - exiting ...."
		exit 1
	else
		echo "using repository at $REPOSITORYDIR"
	fi
	
# --------------------------------------------------------------------------------------------------
	
	
	
# --------------------------------------------------------------------------------------------------
	
	USER=iibadmin
	
	if [ $OPERATION = "install" ] && [ $PRODUCT = "IIB" ] ; then
		
		TARGET_INSTALLDIR=INSTALLDIR_$PRODUCT	
		INSTALL_DIR_TARGET=$(echo "${!TARGET_INSTALLDIR}" | sed 's/ibm/'$env'/g')
		
		if [ ! -d "$INSTALL_DIR_TARGET" ] ; then
			mkdir $INSTALL_DIR_TARGET
		fi
		chmod 644 $REPOSITORYDIR/EAsmbl_image/iib-${INSTALLBASE_IIB}.tar.gz

		tar zxvf $REPOSITORYDIR/EAsmbl_image/iib-${INSTALLBASE_IIB}.tar.gz -C $INSTALL_DIR_TARGET

		# Make a symbolic link so configuration doesn't have to include the version number
		ln -s $INSTALL_DIR_TARGET/iib-${INSTALLBASE_IIB} $INSTALL_DIR_TARGET/iib

		pushd $INSTALL_DIR_TARGET/iib; ./iib make registry global accept license silently ; popd

		# ===============================================================================================================
		# IIB  TODO : change  settup file
		# ===============================================================================================================
		
	else	# update
		# ===============================================================================================================
		# IIB  TODO : change  settup file
		# ===============================================================================================================
		chmod 644 $REPOSITORYDIR/EAsmbl_image/iib-${INSTALLFP_IIB}.tar.gz

		tar zxvf $REPOSITORYDIR/EAsmbl_image/iib-${INSTALLFP_IIB}.tar.gz -C $INSTALL_DIR_TARGET

		# Make a symbolic link so configuration doesn't have to include the version number
		rm -f $INSTALL_DIR_TARGET/iib

		ln -s $INSTALL_DIR_TARGET/iib-${INSTALLFP_IIB} $INSTALL_DIR_TARGET/iib
		
	fi

	# perform verification
	
	cd -
	verifyScript=${ROOTDIR}/verify_${PRODUCT}.bash
	if [[ -f $verifyScript ]] ; then
		msg="$0 - performing validation of ${PRODUCT}"
		log $msg
		msg="Running: $verifyScript ${env}"
		log $msg
		eval "$verifyScript ${env}" | tee -a $LOGILE
	else
		msg="$0 - no verification script \"${verifyScript}\" to run for ${PRODUCT} - please perform manual verification"
		log $msg
	fi
fi

# generate or remove start/stop script
#
#manageStartupScript $OPERATION $PRODUCT $INSTALLDIR

#debug
#echo $PWD
#exit
# setup utilities/tools
#
#if [ -f $UTILS_MQM ] ; then
#	msg="$0 - setting up additional utilities for MQ ...."
#	log $msg
#	su - $TECHUSER -c "tar xvf $UTILS_MQM"				# creates /var/mqm/tools ...."
#	su - $TECHUSER -c "tools/scripts/createQmgrNameSymlink.sh"
#fi

# generate installation target artefact
#
assertBuildTarget $OPERATION $PRODUCT

# finalise logging
#
log "$0 completing; rc=$?"
log " "

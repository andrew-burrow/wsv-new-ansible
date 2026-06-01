#!/bin/bash

#
# program:	install_MQM.bash
# author:	Neil Casey, Syntegrity Solutions for ITSS
# date:		May 14 2015
# pupose:	Install WebSphere MQ Series v8 Server on RHEL6
#


# source the common vars script
#
PROG=`basename $0 .bash`        # get short name of script
ROOTDIR=`dirname $0`            # get dirname to this script

if [ -z "$1" ]
        then
                echo "ERROR : No argument for ENV level supplied- no install will be performed."
		exit 1
        else
                echo "INFO : Performing installation for ${1} ENV."
fi

export ENV=$1
export env=${ENV,,} # lower case
export UENV=${env^^} # upper case

if [[ "$2" =~ "noverify" ]] ; then
	VERIFY="false"
else
	VERIFY="true"
fi


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

MQ_INST=$ENV
initVars $PRODUCT $OPERATION

log "using a specific instance: $MQ_INST"
export RPM_ARGS="--prefix ${INSTALLDIR}"

# define core rpm package prefixes
#
pkgPrefixesCore=(
	MQSeriesRuntime 
	MQSeriesJRE
	MQSeriesGSKit
	MQSeriesClient
	MQSeriesJava
	MQSeriesMan
	MQSeriesSample
	MQSeriesSDK
	MQSeriesServer
)


# verify correct state for PRODUCT to perform OPERATION
#
assessBuildState $OPERATION $PRODUCT

# before proceeding with install run all relevant check scripts
# for this products
#
runCheckScripts $PRODUCT

# filesystem availability / space check
#
checkFS $INSTALLFS $INSTALLFSSIZE
try "du -sh $REPO_ROOT"

# if operation is to uninstall or update then ensure appopriate services are stopped
#
if [ -f /opt/${env}/mqm/bin/setmqenv ] ; then
	. /opt/${env}/mqm/bin/setmqenv -s
	manageServices $OPERATION $PRODUCT
fi


ORIGINAL_REPOSITORYDIR=${REPOSITORYDIR}
#if required create instance RPM's
if [ -n "${MQ_INST}" ]; then
	export TMPDIR=${REPOSITORYDIR}
	case ${OPERATION} in
	install)
		cd ${REPOSITORYDIR}
		./crtmqpkg ${MQ_INST}
		log "setting REPOSITORYDIR to ${REPOSITORYDIR}/mq_rpms/${MQ_INST}/x86_64"
		REPOSITORYDIR=${REPOSITORYDIR}/mq_rpms/${MQ_INST}/x86_64
		;;
	update)
		cd ${REPOSITORYDIR}
		./crtmqfp ${MQ_INST}
		log "setting REPOSITORYDIR to ${REPOSITORYDIR}/mq_rpms/${MQ_INST}/x86_64"
		REPOSITORYDIR=${REPOSITORYDIR}/mq_rpms/${MQ_INST}/x86_64
		;;
	esac	
fi

# proceed with silent install/update
#
log "cd $REPOSITORYDIR"
cd $REPOSITORYDIR
if [ $? != 0 ] ; then	# repository not mounted?
	log "$0 - error: REPOSITORYDIR \"$REPOSITORYDIR\" not visible - exiting ...."
	exit 1
fi
if [ -n "${MQ_INST}" ]; then
	MQLICENCESCRIPT=${ORIGINAL_REPOSITORYDIR}/mqlicense.sh
else
	MQLICENCESCRIPT=./mqlicense.sh
fi
if [ -f $MQLICENCESCRIPT ] ; then
	try "$MQLICENCESCRIPT -accept"
else
	log "$0 - warning: could not find \"$MQLICENCESCRIPT\" - licence previously accepted?"
fi
log "$0 - adding core packages"
pkgadd ${OSARCH} ${pkgPrefixesCore[@]}

#
# Now change the installation name from the default 
# (Installation1, Installation2 etc) to the stack name (sp1, sp2, dv1 etc)
#
# The installation information is stored in /etc/opt/mqm/mqinst.ini
${ROOTDIR}/renameMQInstallation.bash

# perform verification
#
cd -
if [ "$VERIFY" == "true" ] ; then
	. /opt/${MQ_INST}/mqm/bin/setmqenv -s
	verifyScript=${ROOTDIR}/verify_${PRODUCT}.bash
	if [[ -f $verifyScript ]] ; then
		msg="$0 - performing validation of ${PRODUCT}"
		log $msg
		msg="Running: $verifyScript; \$ENV=${ENV}"
		log $msg
		$verifyScript | tee -a $LOGFILE
	else
		msg="$0 - no verification script \"${verifyScript}\" to run for ${PRODUCT} - please perform manual verification"
		log $msg
	fi
fi

# Create utilities directory
UTILDIR=/var/mqm/utilities
mkdir -p $UTILDIR 2>/dev/null
chown mqm:mqm $UTILDIR
chmod 755 $UTILDIR

# Put mqseries script into UTILDIR
cp ${UTILSDIR_BLD}/mqseries $UTILDIR
chown mqm:mqm $UTILDIR/mqseries
chmod 755 $UTILDIR/mqseries

# Put runmqcmd.bash script into UTILDIR
cp ${UTILSDIR_BLD}/runmqcmd.bash $UTILDIR
chown mqm:mqm $UTILDIR/runmqcmd.bash
chmod 755 $UTILDIR/runmqcmd.bash

# Put renewCert.bash script into UTILDIR
cp ${UTILSDIR_BLD}/renewCert.bash $UTILDIR
chown mqm:mqm $UTILDIR/renewCert.bash
chmod 700 $UTILDIR/renewCert.bash

# Put showexpiry.bash script into UTILDIR
cp ${UTILSDIR_BLD}/showexpiry.bash $UTILDIR
chown mqm:mqm $UTILDIR/showexpiry.bash
chmod 700 $UTILDIR/showexpiry.bash

# Put mqm.init script into /etc/init.d
cp ${UTILSDIR_BLD}/mqm.init /etc/init.d
chown root:mqm /etc/init.d/mqm.init
chmod 755 /etc/init.d/mqm.init

# Install standard support packs
install_support_packs
# generate or remove start/stop script
#
#manageStartupScript $OPERATION $PRODUCT $INSTALLDIR

# generate installation target artefact
#
assertBuildTarget $OPERATION $PRODUCT

# finalise logging
#
log "$0 completing; rc=$?"
log " "

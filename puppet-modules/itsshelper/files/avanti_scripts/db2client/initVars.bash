# subroutine "initVars":	initialises variables based on PRODUCT identifier
#
. $INSTALLDIR_BLD/db2rtcl/log.bash
. $INSTALLDIR_BLD/db2rtcl/try.bash

initVars()
{
	PRODUCT=$1
	OPERATION=$2

	S="initVars"

	INSTALLFS=INSTALLFS_${PRODUCT}        	# construct appopriate variable name
	eval INSTALLFS=\$$INSTALLFS           	# dereference variable from commons
	log "INSTALLFS is now $INSTALLFS"

	INSTALLFSSIZE=INSTALLFS_${PRODUCT}_SIZE	# construct appopriate variable name
	eval INSTALLFSSIZE=\$$INSTALLFSSIZE	# dereference variable from commons
	log "INSTALLFSSIZE is now $INSTALLFSSIZE"

	INSTALLFP=INSTALLFP_${PRODUCT}        # construct appopriate variable name
	eval INSTALLFP=\$$INSTALLFP           # dereference variable from commons
	log "INSTALLFP is now $INSTALLFP"

	INSTALLDIR=INSTALLDIR_${PRODUCT}        # construct appopriate variable name
	eval INSTALLDIR=\$$INSTALLDIR           # dereference variable from commons
	log "INSTALLDIR is now $INSTALLDIR"

	PROCSTRING=PROCSTRING_${PRODUCT}        # construct appopriate variable name
	eval PROCSTRING=\$$PROCSTRING           # dereference variable from commons
	log "PROCSTRING is now $PROCSTRING"

	LINUXSERVICE=LINUXSERVICE_${PRODUCT}        # construct appopriate variable name
	eval LINUXSERVICE=\$$LINUXSERVICE           # dereference variable from commons
	log "LINUXSERVICE is now $LINUXSERVICE"

	SPOOLDIR=SPOOLDIR_${PRODUCT}        # construct appopriate variable name
	eval SPOOLDIR=\$$SPOOLDIR           # dereference variable from commons
	log "SPOOLDIR is now $SPOOLDIR"
	if [ ! -e $SPOOLDIR ] ; then
		try "mkdir -p $SPOOLDIR"
	fi

	TECHUSER=TECHUSER_${PRODUCT}		# construct appopriate variable name
	eval TECHUSER=\$$TECHUSER		# dereference variable from commons
	log "$S - TECHUSER is now $TECHUSER"

	TECHGROUP=TECHGROUP_${PRODUCT}		# construct appopriate variable name
	eval TECHGROUP=\$$TECHGROUP		# dereference variable from commons
	log "$S - TECHGROUP is now $TECHGROUP"

	# construct REPOSITORYDIR based on operation and product (as per above logic)
	#
	# NOTE: if the OPERATION is an update then reference the fixpack directory
	#	according to the optionally supplied INSTALLFP_<PRODUCT>, alternately
	#	logic will select the maint/<FIXPACK> wth the highest numeric 4 digit
	#	value, e.g. 8004 would be taken instead of 8001.
	#
	UPDATEVERSION=''
	case $OPERATION in
	'update')
		log "$S - OPERATION is update"
		REPOSITORYDIR=REPO_FIXP_${PRODUCT}  # construct appopriate variable name
		eval REPOSITORYDIR=\$$REPOSITORYDIR # dereference variable from commons
		if [ "X" =  "X"${INSTALLFP} ] ; then
			FP=`ls $REPOSITORYDIR |sort -r | head -1`
		else
			FP=$INSTALLFP
		fi
		REPOSITORYDIR=${REPOSITORYDIR}/${FP}
		#
		# sanity check
		#
		if [ ! -d $REPOSITORYDIR ] ; then
			log "$S - non existent REPOSITORYDIR \"$REPOSITORYDIR\" for version $FP for $OPERATION on $PRODUCT; aborting ...."
			exit 1
		fi
		UPDATEVERSION=`echo $FP | sed -e 's/\.//g'`
		;;
	'install')
		log "$S - OPERATION is install"
		REPOSITORYDIR=REPO_CORE_${PRODUCT}  # construct appopriate variable name
		eval REPOSITORYDIR=\$$REPOSITORYDIR # dereference variable from commons
		;;
	'uninstall')
		log "$S - OPERATION is uninstall"
		REPOSITORYDIR=REPO_CORE_${PRODUCT}  # construct appopriate variable name
		eval REPOSITORYDIR=\$$REPOSITORYDIR # dereference variable from commons
		;;
	*)
		log "$S - warning: OPERATION $OPERATION unsupported"
		REPOSITORYDIR=REPO_CORE_${PRODUCT}  # construct appopriate variable name
		eval REPOSITORYDIR=\$$REPOSITORYDIR # dereference variable from commons
		;;
	esac
	log "$S - REPOSITORYDIR is now $REPOSITORYDIR"

	# setup Config directory
	#
	CONFIGDIR=$CONFIGROOT/cfg
	if [ ! -e $CONFIGDIR ] ; then
		try "mkdir -p $CONFIGDIR"
	fi

	# setup Eclipse Cache Directory
	#
	ECLIPSECACHEDIR=$SPOOLDIR_ECD
	if [ ! -e $ECLIPSECACHEDIR ] ; then
		try "mkdir -p $ECLIPSECACHEDIR"
	fi

	# setup Script directory
	#
	SCRIPTDIR=$SCRIPTROOT/bin
	if [ ! -e $SCRIPTDIR ] ; then
		try "mkdir -p $SCRIPTDIR"
	fi

	# setup install verificiation (security health check) directory
	#
	SHCDIR=$CONFIGROOT/shc
	if [ ! -e $SHCDIR ] ; then
		try "mkdir -p $SHCDIR"
	fi

        # define pre-install check scripts
	# NOTE: additional scripts can be defined and added to this list
        #
        CHECKSCRIPTS=( 
                        "${INSTALLDIR_BLD}/bin/check_uidgid.bash $TECHUSER $TECHGROUP"
			${INSTALLDIR_BLD}/bin/check_pkgdepend_${PRODUCT}.bash 
			${INSTALLDIR_BLD}/bin/check_sysvipc_${PRODUCT}.bash 
			${INSTALLDIR_BLD}/bin/check_mof_${PRODUCT}.bash 
			${INSTALLDIR_BLD}/bin/check_maxproc_${PRODUCT}.bash 
	)

}


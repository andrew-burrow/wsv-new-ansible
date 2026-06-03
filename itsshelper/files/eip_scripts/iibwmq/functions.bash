# subroutine "log":	logs an operation
#
log()
{
    line="$@"
    now=`date +"%Y-%m-%d %H:%M:%S"`
    message="$now	$line"
    echo $message | tee -a $LOGFILE
}

# subroutine "try":    	performs the operation and tests that return code is 0
#			if return code is not zero exits with error code	
#

try()
{
	cmd="$@"
	#S='try'
	msg="performing: \"$cmd\""
	log $msg
	set -o pipefail
	$cmd 2>&1 | tee -a $LOGFILE
	rc=$?
	if [[ $rc -ne 0 ]] ; then
		msg="try - error: $cmd failed rc=$rc - see errorlog $LOGFILE"
		log $msg
		if $IGNOREERRORS ; then
			msg="try - ignoring error and continuing ...."
			log $msg
		else
			msg="try - exiting on this error"
			log $msg
			exit 1
		fi
	else
		log "	OK"
	fi

	# implicitly return rc - in case IGNOREERRORS logic is being used
}

# subroutine assertBuildTarget:	Creates a build artefact post successfull component install
#

assertBuildTarget()
{
	OPERATION=$1
        PRODUCT=$2
	S='assertBuildTarget'

	if [ -z "${ENV}" ] ; then
		SHCLOG=$SHCDIR/${OPERATION}_${PRODUCT}
	else
		SHCLOG=$SHCDIR/${OPERATION}_${PRODUCT}_${ENV}
	fi
	if [ $OPERATION != "uninstall" ] ; then
		case $PRODUCT in
		'DB2')
			VERIFYCMD=`which db2level`
			if [ -z $VERIFYCMD ] ; then
				VERIFYCMD="/home/${TECHUSER_DB2}/sqllib/bin/db2level"
				log "$S - warning: no db2level command was found for $PRODUCT - using default $VERIFYCMD"
			fi
			log "$S - performing: $VERIFYCMD > $SHCLOG"
			$VERIFYCMD > $SHCLOG || echo "$S failed to perform \"$VERIFYCMD\""
			;;
		'IHS'|'PLG'|'WAS')
			VERIFYCMD=${INSTALLDIR}/bin/versionInfo${SFXB}
			if [ ! -f $VERIFYCMD ] ; then
				log "$S - warning: no $VERIFYCMD command was found for $PRODUCT"
				VERIFYCMD=""
			else
				VERIFYCMD="$VERIFYCMD -file $SHCLOG"
				log "$S - performing: $VERIFYCMD"
				cd ${INSTALLDIR}/bin
				./versionInfo${SFXB} -file $SHCLOG || echo "$S failed to perform \"$VERIFYCMD\""
				cd -
			fi
			;;
		'IM')
			# VERIFYCMD="/opt/IBM/InstallationManager/eclipse/tools/imcl"
			VERIFYCMD="${INSTALLDIR}/tools/imcl${SFXE}"
			if [ -z $VERIFYCMD ] ; then
				log "$S - warning: no $VERIFYCMD command was found for $PRODUCT"
				VERIFYCMD="/home/db2iadm1/sqllib/bin/db2level"
			else
				log "$S - performing: $VERIFYCMD -version > $SHCLOG"
				cd ${INSTALLDIR}/tools
				./imcl${SFXE} -version > $SHCLOG || echo "$S failed to perform \"$VERIFYCMD\""
				cd -
			fi
			;;
		'LMT')
			VERIFYCMD="${INSTALLDIR}/tlmagent${SFXE}"
			if [ -z $VERIFYCMD ] ; then
				log "$S - warning: no $VERIFYCMD command was found for $PRODUCT"
				VERIFYCMD=""
			else
				log "$S - performing: $VERIFYCMD -v> $SHCLOG"
				cd $INSTALLDIR
				./tlmagent${SFXE} -v > $SHCLOG || echo "$S failed to perform \"$VERIFYCMD\""
			fi
			;;
		'MQM')
			VERIFYCMD=/opt/${ENV}/mqm/bin/dspmqver
			if [ ! -e $VERIFYCMD ] ; then
				log "$S - warning: no dspmqver command was found for $PRODUCT"
				VERIFYCMD=""
			else
				log "$S - performing: $VERIFYCMD > $SHCLOG"
				$VERIFYCMD > $SHCLOG || echo "$S failed to perform \"$VERIFYCMD\""
			fi
			;;
		'IIB')
			VERIFYCMD=/opt/${ENV}/iib-${INSTALLBASE_IIB}/iib
			VERSIONOPTS="level"
			if [ ! -e $VERIFYCMD ] ; then
				log "$S - warning: no iib command was found for $PRODUCT"
				VERIFYCMD=""
			else
				log "$S - performing: $VERIFYCMD > $SHCLOG"
				$VERIFYCMD $VERSIONOPTS >> $SHCLOG || echo "$S failed to perform \"$VERIFYCMD\""
			fi
			;;
		*)
			log "$S - $PRODUCT is invalid - aborting ...."
			exit 1
			;;
		esac

		# search for a version pattern in the VERIFYCMD output and
		# alter the name of the VERIFYCMD output file with this value 
		#
		if [ ! -z "$VERIFYCMD" ] ; then
			# look for typical version format e.g. "Version[:] WW.XX.YY.ZZ"
			#
			VERSINFO=`cat $SHCLOG | egrep "^Version[:]*\s+[[:digit:]]" | awk '{print $2}'`
			# echo "$S VERSINFO => $VERSINFO"
			if [ -z $VERSINFO ] ; then
				# look for something like vWW.XX.YY.ZZ
				# e.g. Informational tokens are "DB2 v9.7.0.6"
				#
				VERSINFO=`cat $SHCLOG | egrep "v[:]*[[:digit:]]"`
				# if [[ $VERSINFO =~ v[:]*([[:digit:]]).* ]] ; then
				if [[ $VERSINFO =~ v[:]*([0-9\.]+) ]] ; then
					VERSINFO=${BASH_REMATCH[1]}
				fi
				# look for something like "version <number>"
				# e.g. tlmagent version 7.2.2.0 - Build 201011302237
				#
				if [ -z $VERSINFO ] ; then
					log "$S - looking for tlmagent style version"
					VERSINFO=`cat $SHCLOG | egrep "version"`
					if [[ $VERSINFO =~ version[[:space:]]([0-9\.]+) ]] ; then
						VERSINFO=${BASH_REMATCH[1]}
					fi
				fi
				# look for something like "Version:     '<number>'"
				# e.g. Version:    '10000'
				# This is produced by IIB v10 and higher
				#
				if [ -z $VERSINFO ] ; then
					log "$S - looking for IIB style Version:"
					VERSINFO=`cat $SHCLOG | egrep "^Version:[[:blank:]]+'[[:digit:]]*'"`
					if [[ $VERSINFO =~ ([0-9]+) ]] ; then
						VERSINFO=${BASH_REMATCH[1]}
					fi
				fi


			else
				log "$S - VERSINFO => $VERSINFO"
				#VERSINFO=`echo $VERSINFO | awk '{print $2}'`
			fi
			msg="$S - PRODUCT $PRODUCT OPERATION $OPERATION VERSINFO=$VERSINFO"
			log $msg
			try "mv $SHCLOG ${SHCLOG}_${VERSINFO}.log"
		fi
	else	# uninstall - remove former build target files
		#
		for file in `ls ${SHCDIR}/*_${PRODUCT}_${ENV}*` ; do
			log "$S - successfull $OPERATION on $PRODUCT will remove $file"
			try "rm $file"
		done
	fi

	#/opt/IBM/WebSphere/AppServer/bin/versionInfo.sh |grep Version
	#  WVER0012I: VersionInfo reporter version 1.15.1.47, dated 10/18/11
	#  Version Directory        /opt/IBM/WebSphere/AppServer/properties/version
	#  Version               8.0.0.4
	#  Installed Features    IBM 64-bit SDK for Java, Version 6
	#/opt/IBM/HTTPServer/bin/versionInfo.sh |grep Version
	#  WVER0012I: VersionInfo reporter version 1.15.1.47, dated 10/18/11
	#  Version Directory        /opt/IBM/HTTPServer/properties/version
	#  Version               8.0.0.4
	#  Installed Features    IBM HTTP Server 64-bit with Java, Version 6
	#/opt/IBM/Plugins/bin/versionInfo.sh |grep Version
	#  WVER0012I: VersionInfo reporter version 1.15.1.47, dated 10/18/11
	#  Version Directory        /opt/IBM/Plugins/properties/version
	#  Version               8.0.0.4
	#  Installed Features    IBM 64-bit Runtime Environment for Java, Version 6
	#dspmqver | grep Version
	#  Version:     7.0.1.9

}

# subroutine assessBuildState:	Assesses whether desired operation for product
#				makes statefull sense.
# RULES:
#	1. Can only perform an install if no previous install was done
#		i.e. there is no install_<PRODUCT>_<VERSION> build target.
#	2. Can only perform an update if a previous update or install was done
#		i.e. there must exist an update_<PRODUCT>_<VERSION> or failing
#		that an install_<PRODUCT>_<VERSION> build target.
#		In either case, UPDATEVERSION has to be higher than the 
#		current PRODUCT VERSION visible in existing build target name.
#	3. Can only perform an uninstall if there exists a build target, i.e
#		install_<PRODUCT>_<VERSION> or update_<PRODUCT>_<VERSION> 
#
# SORTing:
#	Updates will be found first, followed last by installs:
#	update_<PRODUCT>_<VERSION>
#	install_<PRODUCT>_<VERSION>
#

assessBuildState()
{
    OPERATION=$1
    PRODUCT=$2
    
    S='assessBuildState'
    
    set -o pipefail
    cd ${SHCDIR}
    CURRENTVERSION=`ls *_${PRODUCT}_${ENV}* | sort -r | head -1`
    CURRENTVERSIONMQM=`ls *_MQM_* | sort -r | head -1`
    CURRENTVERSIONIIB=`ls *_IIB_* | sort -r | head -1`
    log "$S - assessing if $OPERATION on $PRODUCT is allowed given current state $CURRENTVERSION"
    
    case $OPERATION in
        'install')	# RULE 1
	    if [ "X" = "X"${CURRENTVERSION} ] ; then              # no current version found
		if [ $PRODUCT != "IM" -a "X" = "X"${CURRENTVERSIONIM} ] ; then	# not installing IM and also no IM present
		  if [ $PRODUCT = "IHS" -o $PRODUCT = "PLG" -o $PRODUCT = "WAS" ] ; then
		    log "$S - determined no dependant installation manager ${SHCDIR}/${OPERATION}_IM* therefore NOT ok to $OPERATION"
		    exit 1
		  else
		    log "$S - no IM and no current ${SHCDIR}/${OPERATION}_${PRODUCT}* therefore ok to $OPERATION"
		  fi
		else
		    log "$S - prod=IM or currentVersionIM not blank [ ${CURRENTVERSIONIM} ] and no current ${SHCDIR}/${OPERATION}_${PRODUCT}* therefore ok to $OPERATION"
		fi
	    else
		log "$S - determined there is already a $CURRENTVERSION therefore NOT ok to $OPERATION"
		exit 1	
	    fi
            ;;
        'update')	# RULE 2
	    if [ -z $CURRENTVERSION ] ; then
		msg="$S - determined no current ${SHCDIR}/*_${PRODUCT}* therefore NOT ok to $OPERATION"
		log $msg
		exit 1
	    else	# CURRENTVERSION exists - determine if $UPDATEVERSION exceeds this
		if [ ! -z $UPDATEVERSION ] ; then
				#if [[ $VERSINFO =~ v[:]*([0-9\.]+) ]] ; then
		    if [[ $CURRENTVERSION =~ ([0-9\.]+) ]] ; then
			VERSINFO=`echo ${BASH_REMATCH[1]} | sed -e 's/\.//g'`
			log "$S - test if \"$UPDATEVERSION -gt $VERSINFO\""
			if [ $UPDATEVERSION -gt $VERSINFO ] ; then
			    msg="$S - ok to apply $UPDATEVERSION over current $VERSINFO ...."
			    log $msg
			else
			    msg="$S - invalid to apply $UPDATEVERSION over current $VERSINFO - aborting ...."
			    log $msg
			    exit 1
			fi
		    else
			msg="$S - failed to determine VERSINFO from $CURRENTVERSION - aborting ...."
			log $msg
			exit 1
		    fi
		else	# no UPDATEVERSION
		    msg="$S - has determined there is no $UPDATEVERSION to update to - aborting ...."
		    log $msg
		    exit 1
		fi
	    fi
            ;;
        'uninstall')	# RULE 3
	    if [ -z $CURRENTVERSION ] ; then
		msg="$S - determined there is/are NO current $SHCDIR/\*_${PRODUCT}\* targets therefore can not $OPERATION"
		log $msg
		exit 1	
	    else
		if [ $PRODUCT = "IM" ] ; then
		    if [ "X"${CURRENTVERSIONIHS} != "X" -o "X"${CURRENTVERSIONWAS} != "X" -o "X"${CURRENTVERSIONPLG} != "X" ] ; then
			log "$S - determined there are still dependant installation manager components therefore NOT ok to $OPERATION"
			exit 1
		    fi
		else
		    log "$S - determined current build state $CURRENTVERSION therefore ok to $OPERATION"
		fi
	    fi
            ;;
        *)
            msg="$S - OPERATION $OPERATION unsupported in subroutine assessBuildTarget - aborting ...."
	    log $msg
	    exit 1	
            ;;
    esac
}

# subroutine "checkFS":         checks filesytem
#

checkFS()
{
        FSNAME=$1
        FSSIZE=$2
        try "df -h $FSNAME"
        if [ ! -z $FSSIZE ] ; then      # size check
                FSMEGS=`df -Pm $FSNAME | tail -1 | awk '{print $4}'`
                if [ $FSMEGS -lt $FSSIZE ] ; then
                        msg="error: filesystem space - $FSNAME is only ${FSMEGS}M but should be at least ${FSSIZE}M"
                        log $msg
                        exit 1
                fi
        fi
}
# declareDefaults	- declare all default vars in case not sourced from props file
#
declareDefaults()
{
    CHMODMASK=750					# postinstall mask to be applied to installed binaries
    
    CONFIGROOT=${INSTALLDIR_BLD}			# root of where stuff can be found
    
    # location of jython resources to deploy a simple sample app
    #
    IGNOREERRORS=false					# fail on an error occuring - used by try() subroutine
    
    INSTALLROOT=/opt/IBM				# common target root for binary install
							# NOTE: this is a local var and has no PROPSFILE equivalent
   
    INSTALLBV_MQM=8.0.0.0				# Base Version of IBM WebSphere MQ Series Server (MQM)
    INSTALLDIR_MQM=/opt/${ENV}/mqm				# installation target directory for MQ Series
							# IMPORTANT: INSTALLDIR_MQM is used to set up RPM config
    INSTALLFP_MQM=8.0.0.4				# MQM fixpack
    INSTALLFS_MQM=/opt					# target filesystem
    INSTALLFS_MQM_SIZE=2000				# min. size in M of MQM

    JAVA=/usr/bin/java					# java home

    REPOROOT=/opt/staging				# IBM eAssemblies file system (for binary install)
    REPO_CORE_MQM=$REPOROOT/mqm8x/base		# post expansion location of eAssembly - core MQ Series
    REPO_FIXP_MQM=$REPOROOT/mqm8x/maint		# location of eAssembly patch subdirs fixpack MQ Series
   
    RETRYCOUNT=10					# max addNode attempts
    RETRYTIME=30					# addNode() retry in case dmgr is busy 
    #OSNAME="Linux"					# platform type
    OSARCH="64"						# base architecture expected (32/64 bit)
    OSVERS="6"						# base OS version expected
   
    PROCSTRING_MQM=mqm					# process string identifier for MQM
    
    SPOOLROOT=/var/spool/IBM				# Spool root of all IBM installed products
    
    TECHUSER_MQM=mqm					# postinstall MQM owner to be applied to installed binaries

}
# declare all other vars based on properties declared vars or defaultVars()
#
declareVars()
{
    SCRIPTROOT=$CONFIGROOT				# location of generated run level 3 scripts
    
    SPOOLDIR_LOG=${SPOOLROOT}/logs                  # spool for install / build script logs
    SPOOLDIR_MQM=/var/mqm				# spool for MQM queue managers/transaction logs/utils
    
    TECHGROUP_MQM=$TECHUSER_MQM		# postinstall MQM group to be applied to installed binaries
    
    
}

# subroutine "initLogs"	- gets invoked by default to initialise logs
#

initLogs()
{
	nameSpace=$1
	OSNAME=$2
	WHOAMI=`whoami`

	# setup default Logging directory and file
	# NOTE: these values will be over-ridden in the initVars routine
	#
	LOGFILE=$SPOOLDIR_LOG/install.log
	if [ ! -e $SPOOLDIR_LOG ] ; then
	 	mkdir -p $SPOOLDIR_LOG
		chmod 755 $SPOOLDIR_LOG
	fi
	if [ ! -f $LOGFILE ] ; then
	 	touch $LOGFILE
		chmod 777 $LOGFILE
	fi

	log
	log "$nameSpace $VERSION $VERDATE started"
	log "LOGFILE set to $LOGFILE"
	log
}

# subroutine "initVars":	initialises variables based on PRODUCT identifier
#

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
	'create'|'delete')
		log "$S - OPERATION is create"
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
	export CONFIGDIR=${INSTALLDIR_BLD}/properties

	# setup Script directory
	#
	#SCRIPTDIR=$SCRIPTROOT/scripts
	#if [ ! -e $SCRIPTDIR ] ; then
	#	try "mkdir -p $SCRIPTDIR"
	#fi

	# setup Utils source directory
	#
        UTILSDIR_BLD=${REPOSITORYDIR}/../../tools  # Source of MQ utils and scripts
        log "$S - UTILSDIR_BLD is now $UTILSDIR_BLD"

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
                        "${ROOTDIR}/check_uidgid.bash $TECHUSER $TECHGROUP"
			${ROOTDIR}/check_pkgdepend_${PRODUCT}.bash 
			${ROOTDIR}/check_sysvipc_${PRODUCT}.bash 
			${ROOTDIR}/check_mof_${PRODUCT}.bash 
			${ROOTDIR}/check_maxproc_${PRODUCT}.bash 
	)

}

# subroutine: installSupportPacks
#	      Installs MQ Support packs
# usage:      install_<supportPackName>
#	      instaal_support_packs
#
# Provides installers for the following support packs
#	ma01
#	mh04
#	mh05
#	mh06
#	mo03

# Relies on environment variables:
#	UTILSDIR_BLD


UTILSDIR_TGT=/var/mqm/utilities

replacefile()
{
	fname=$(basename "$1")
	if [ -d "$2" ] ; then
		target="$2/$fname"
	else
		target="$2"
	fi
	if [ -e "$target" ] ; then
		rm -f "$target"
	fi
	if [ -f "$1" ] ; then
		cp "$1" "$2"
	fi
}

install_ma01()
{
if [ ! -e $UTILSDIR_BLD/ma01.zip ] ; then	
	msg="$S - warning: no installation package for ma01 found - ignoring ...."
	echo $msg
	log $msg
else
	if [ -e /tmp/ma01 ] ; then
		rm -rf /tmp/ma01
	fi
	mkdir /tmp/ma01
	unzip $UTILSDIR_BLD/ma01.zip -d /tmp/ma01
	replacefile "/tmp/ma01/V6.0/Linux Intel 64/q" $UTILSDIR_TGT/q.bin
	chown mqm:mqm $UTILSDIR_TGT/q.bin
	chmod 755 $UTILSDIR_TGT/q.bin
	replacefile "$UTILSDIR_BLD/q.bash" $UTILSDIR_TGT/q
	chown mqm:mqm $UTILSDIR_TGT/q
	chmod 755 $UTILSDIR_TGT/q
	rm -rf /tmp/ma01
	msg="$S - info: installation of ma01 - complete ...."
	echo $msg
	log $msg
fi
}

install_mh04()
{
if [ ! -e $UTILSDIR_BLD/mh04.zip ] ; then	
	msg="$S - warning: no installation package for mh04 found - ignoring ...."
	echo $msg
	log $msg
else
	if [ -e /tmp/mh04 ] ; then
		rm -rf /tmp/mh04
	fi
	mkdir /tmp/mh04
	unzip $UTILSDIR_BLD/mh04.zip -d /tmp/mh04
	replacefile "/tmp/mh04/com.ibm.xmq.utilities.jar" $UTILSDIR_TGT
	chown mqm:mqm $UTILSDIR_TGT/com.ibm.xmq.utilities.jar
	chmod 644 $UTILSDIR_TGT/com.ibm.xmq.utilities.jar
	replacefile $UTILSDIR_BLD/xmqqstat.bash $UTILSDIR_TGT
	chown mqm:mqm $UTILSDIR_TGT/xmqqstat.bash
	chmod 755 $UTILSDIR_TGT/xmqqstat.bash
	replacefile $UTILSDIR_BLD/xmqqstab.bash $UTILSDIR_TGT
	chown mqm:mqm $UTILSDIR_TGT/xmqqstab.bash
	chmod 755 $UTILSDIR_TGT/xmqqstab.bash
	rm -rf /tmp/mh04
	msg="$S - info: installation of mh04 - complete ...."
	echo $msg
	log $msg
fi
}

install_mh05()
{
if [ ! -e $UTILSDIR_BLD/mh05.zip ] ; then	
	msg="$S - warning: no installation package for mh05 found - ignoring ...."
	echo $msg
	log $msg
else
	if [ -e /tmp/mh05 ] ; then
		rm -rf /tmp/mh05
	fi
	mkdir /tmp/mh05
	unzip $UTILSDIR_BLD/mh05.zip -d /tmp/mh05
	replacefile "/tmp/mh05/com.ibm.xmq.events.jar" $UTILSDIR_TGT
	chown mqm:mqm $UTILSDIR_TGT/com.ibm.xmq.events.jar
	chmod 644 $UTILSDIR_TGT/com.ibm.xmq.events.jar
	replacefile $UTILSDIR_BLD/xmqdspev.bash $UTILSDIR_TGT
	chown mqm:mqm $UTILSDIR_TGT/xmqdspev.bash
	chmod 755 $UTILSDIR_TGT/xmqdspev.bash
	rm -rf /tmp/mh05
	msg="$S - info: installation of mh05 - complete ...."
	echo $msg
	log $msg
fi
}

install_mh06()
{
if [ ! -e $UTILSDIR_BLD/mh06.zip ] ; then	
	msg="$S - warning: no installation package for mh06 found - ignoring ...."
	echo $msg
	log $msg
else
	if [ -e /tmp/mh06 ] ; then
		rm -rf /tmp/mh06
	fi
	mkdir /tmp/mh06
	unzip $UTILSDIR_BLD/mh06.zip -d /tmp/mh06
	replacefile "/tmp/mh06/mqapitrcstats.linux" $UTILSDIR_TGT/mqapitrcstats
	chown mqm:mqm $UTILSDIR_TGT/mqapitrcstats
	chmod 755 $UTILSDIR_TGT/mqapitrcstats
	replacefile "/tmp/mh06/mqoptions.linux" $UTILSDIR_TGT/mqoptions
	chown mqm:mqm $UTILSDIR_TGT/mqoptions
	chmod 755 $UTILSDIR_TGT/mqoptions
	replacefile "/tmp/mh06/mqtrcfrmt.linux" $UTILSDIR_TGT/mqtrcfrmt
	chown mqm:mqm $UTILSDIR_TGT/mqtrcfrmt
	chmod 755 $UTILSDIR_TGT/mqtrcfrmt
	rm -rf /tmp/mh06
	msg="$S - info: installation of mh06 - complete ...."
	echo $msg
	log $msg
fi
}

install_mo03()
{
if [ ! -e $UTILSDIR_BLD/mo03.zip ] ; then	
	msg="$S - warning: no installation package for mo03 found - ignoring ...."
	echo $msg
	log $msg
else
	if [ -e /tmp/mo03 ] ; then
		rm -rf /tmp/mo03
	fi
	mkdir /tmp/mo03
	unzip $UTILSDIR_BLD/mo03.zip -d /tmp/mo03
	replacefile "/tmp/mo03/V1.9/Linux Intel 64/qload" \
		$UTILSDIR_TGT/qload.bin
	chown mqm:mqm $UTILSDIR_TGT/qload.bin
	chmod 755 $UTILSDIR_TGT/qload.bin
	replacefile "$UTILSDIR_BLD/qload.bash" $UTILSDIR_TGT/qload
	chown mqm:mqm $UTILSDIR_TGT/qload
	chmod 755 $UTILSDIR_TGT/qload
	rm -rf /tmp/mo03
	msg="$S - info: installation of mo03 - complete ...."
	echo $msg
	log $msg
fi
}

install_support_packs()
{
	install_ma01
	install_mh04
	install_mh05
	install_mh06
	install_mo03
}

# subroutine manageServices:    Stops/Start the service as appopriate
#				NOTE at this stage we only wish to stop
#				a service prior to uninstall or update.
#				Starting the service after an install
#				can only be performed after configuration
#				is performed.
#

manageServices()
{
	OPERATION=$1
        PRODUCT=$2

	s=manageServices

	if [ $OPERATION != "install" ] ; then
		SCRIPT=$ROOTDIR/manage${PRODUCT}${SFXB}
		if [ -f $SCRIPT ] ; then
			msg="invoking start/stop script \"$SCRIPT stop\" ...."
			log $msg
			if [[ $PRODUCT = "WAS" && $OSTYPE = "Linux" ]] ; then
				su - $TECHUSER -c "$SCRIPT stop"
			else
				$SCRIPT stop
			fi
			#
			# at this stage need to wait for all processes to stop
			#
			running=true
			while $running ; do
				PROCS=`ps -ef | grep $PROCSTRING | grep -v grep | wc -l`
				if [[ $PROCS -eq 0 ]] ; then
					running=false
				else
					log "still waiting for $PROCS processes containing \"$PROCSTRING\" to complete ...."
					sleep 10
				fi
			done
		else
			msg="$s: warning - no script $SCRIPT found to invoke for PRODUCT $PRODUCT on OPERATION $OPERATION"
			log $msg
		fi
	fi
}
# subroutine: pkgadd
#	      adds rpm packages
# usage:      pkgadd {filter} {pkg-prefix-1 [.. pkg-prefix-n]}
#

pkgadd()
{
	S='pkgadd'

	FILTER=$1
	shift
	PKGPREFIXES=$*

        for pkgPrefix in $PKGPREFIXES
        do
                :
                pkg=`ls ${pkgPrefix}*|grep ${FILTER}`
                if [[ $pkg != "" ]] ; then
                        # add new package update
                        #
                        try "rpm ${RPM_ARGS} -ivh $pkg"
                else
                        msg="$S - warning: no package found with prefix ${pkgPrefix} for arch. ${OSARCH} - ignoring ...."
                        echo $msg
                        log $msg
                fi
        done
}
# subroutine: pkgrm
#	      removes rpm packages
# usage:      pkgrm {filter}
#

pkgrm()
{
    pkgPrefix=$1
	pkgVersion=$2
	
	if [[ $pkgPrefix == "MQSeries" ]] ; then
		# uninstall MQ - updated during MQ 9.3 upgrade
		pkgsMQ=`rpm -qa |grep -E ${pkgPrefix}.*_${pkgVersion}-`
		if [[ $pkgsMQ != "" ]] ; then
			while [[ $pkgsMQ != "" ]] ; do
				fpVersion=`rpm -qa |grep -E ${pkgPrefix}.*_${pkgVersion}- |grep -Eo '[0-9]+.'x86_64 |sort -run |head -n 1`
				mqpkgs=`rpm -qa |grep -E ${pkgPrefix}.*_${pkgVersion}-.*${fpVersion}`			
				rpm -ev ${mqpkgs[@]}
				pkgsMQ=`rpm -qa |grep -E ${pkgPrefix}.*_${pkgVersion}-`
			done						
        else
                msg="warning: no package(s) found with prefix $pkgPrefix $pkgVersion to be uninstalled- ignoring ...."
                echo $msg
                log $msg
        fi
	else
        pkgs=`rpm -qa |grep -E ${pkgPrefix}.*_${pkgVersion}-`
        if [[ $pkgs != "" ]] ; then
                # remove rpm packages at same time to avoid dependency check
                # violations
                #
                try "rpm -ev ${pkgs[@]}"
        else
                msg="warning: no package(s) found with prefix $pkgPrefix $pkgVersion - ignoring ...."
                echo $msg
                log $msg
        fi
	fi
}

# subroutine runCheckScripts:	Runs the pre-install check scripts associated with this PRODUCT
#

runCheckScripts()
{
	PRODUCT=$1

	S='runCheckScripts'

	# note that the CHECKSCRIPTS array should have been populated
	# during the initVars() function 
	#
	if [ $OSTYPE = "Linux" ] ; then
	for CHECKSCRIPT in "${CHECKSCRIPTS[@]}" ; do
		SCRIPTPART=`echo "$CHECKSCRIPT" | awk '{print $1}'`
		log "$S - examining check script \"$SCRIPTPART\" ...."
		if [ -f $SCRIPTPART ] ; then
			msg="Running pre-install check script $CHECKSCRIPT for $PRODUCT ...."
			log $msg
			$CHECKSCRIPT
			if [ $? != 0 ] ; then
				msg="error: Check script $CHECKSCRIPT ended with a non zero return code."
				log $msg
				msg="       Please run the script $CHECKSCRIPT and address the issues noted."
				log $msg
				msg="       You should then run the script again when all issues are resolved,"
				log $msg
				msg="       then rerun this installation script. Thank-you."
				log $msg
				exit 1
			fi
		else
			msg="No check script $CHECKSCRIPT for $PRODUCT .... ignoring"
			log $msg
		fi
	done
	fi
}

# subroutine "encryptPwd":	decrypts the pwd
#
encryptPwd()
{
  decryptedPwd=$1
  encryptedPwd=$(echo ${decryptedPwd} | openssl enc -aes-256-cbc -base64 -A -salt -pass file:${CONFIGDIR}/pwd_salt)
  echo ${encryptedPwd}
}

# subroutine "decryptPwd":	decrypts the pwd
#
decryptPwd()
{
  encryptedPwd=$1
  decryptedPwd=$(echo ${encryptedPwd} | openssl enc -aes-256-cbc -base64 -A -d -salt -pass file:${CONFIGDIR}/pwd_salt)
  echo ${decryptedPwd}
}

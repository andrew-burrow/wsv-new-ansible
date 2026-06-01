# subroutine "initLogs"	- gets invoked by default to initialise logs
#
. $INSTALLDIR_BLD/db2rtcl/log.bash

initLogs()
{
	nameSpace=$1
	OSNAME=$2
	WHOAMI=`whoami`

	# setup default Logging directory and file
	# NOTE: these values will be over-ridden in the initVars routine
	#
	LOGFILE=$SPOOLDIR_LOG${PS}install.log
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


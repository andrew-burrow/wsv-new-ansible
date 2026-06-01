# subroutine "try":    	performs the operation and tests that return code is 0
#			if return code is not zero exits with error code	
#
. $INSTALLDIR_BLD/db2rtcl/log.bash

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

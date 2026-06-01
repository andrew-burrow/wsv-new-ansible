# subroutine "sysCheck"	- gets invoked by default to check os name/type etc.
#
. $INSTALLDIR_BLD/db2rtcl/log.bash
. $INSTALLDIR_BLD/db2rtcl/try.bash

sysCheck()
{
	nameSpace=$1
	OSNAME=$2
	WHOAMI=`whoami`

	try "id"
	if [ ${OSNAME} = 'Linux' ] ; then
		log "OSNAME is Linux"
		try "grep $OSVERS /etc/redhat-release"
		cmd="uname -a | egrep ${OSNAME} | grep ${OSARCH}"
		result=`uname -a | egrep "${OSNAME}" | grep "${OSARCH}"`
	else
		# windows - need to examine how to determine exact architecture
		#
		log "OSNAME is $OSNAME (not Linux)"
		cmd="uname -a | egrep ${OSNAME} | grep ${OSARCH}"
		result=`uname -a | egrep "${OSNAME}"`
	fi
	if [ $? != 0 ] ; then
		log "error: $cmd failed \"$result\""
		echo "error: $cmd failed \"$result\""
		exit $?
	else
		log "$cmd OK \"$result\""
	fi

}


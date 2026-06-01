# expand the DB2 Client EAssembly and cd into the expanded path
#
. $INSTALLDIR_BLD/db2rtcl/log.bash
. $INSTALLDIR_BLD/db2rtcl/try.bash

expandIntoDB2()
{
	# enter into DB2 eassembly repository
	#
	log "cd $REPOSITORYDIR"
	cd $REPOSITORYDIR

	# unzip eassembly contents into staging area
	#
	EASSEMBLY=`ls ${REPOSITORYDIR}${PS}${EASSEMBLY_DB2}.*`
	if [ ! -z ${EASSEMBLY} ] ; then
		try "tar -zxf ${EASSEMBLY}"
	else
		if [ -f "${EASSEMBLY}.tar" ] ; then
			try "tar xf ${EASSEMBLY}.tar"
		else
			log "error: failed to find eassembly ${EASSEMBLY}.* in $REPOSITORYDIR"
			exit 1
		fi
	fi

	# untar eassembly contents into staging area
	#
	CDINTODB2=`tar tvf ${EASSEMBLY} | head -1 | awk '{print $6}'`
	log "cd ${REPOSITORYDIR}${PS}${CDINTODB2}"
	cd ${REPOSITORYDIR}${PS}${CDINTODB2}
}

# subroutine createResponseFile:	Created response file for silent install
#					of PRODUCT based on that PRODUCT's
#					pre-created silent response file template
#					and substitutes appopriate vars
#
. $INSTALLDIR_BLD/db2rtcl/log.bash
. $INSTALLDIR_BLD/db2rtcl/try.bash

createResponseFile()
{
	OPERATION=$1			# TYPE="install" or "uninstall"
	PRODUCT=$2			# PRODUCT=DB2,IHS,[MQM],WAS,PLG,JDK

	s=createResponseFile

	log "$s $OPERATION $PRODUCT"
	if [ $PRODUCT = "DB2" ] ; then
		CFGTEMPL=$INSTALLDIR_BLD/db2rtcl/${OPERATION}_${PRODUCT}_template.rsp
	fi
	if [ $OSTYPE != "Linux" ] ; then
		CFGTEMPLWIN=$INSTALLDIR_BLD/db2rtcl/${OPERATION}_${PRODUCT}_${OSTYPE}_template.xml
		if [ -f $CFGTEMPLWIN ] ; then
			CFGTEMPL=$CFGTEMPLWIN
		fi
	fi
	SUFX=`echo $CFGTEMPL | awk -F. '{print $NF}'`
	CFG="${CONFIGDIR}/${OPERATION}_${PRODUCT}.${SUFX}"
	# try "if [ -e $CFGTEMPL ] ; then echo \"template $CFGTEMPL ok\" ; fi"
	if [ -e $CFGTEMPL ] ; then 
		log "generating silent ${OPERATION} response file $CFG from template $CFGTEMPL ...."
	else
		log "no template silent ${OPERATION} response file exists for $PRODUCT as \"$CFGTEMPL\" - aborting ...."
		exit 1
	fi
	CFGTMP=${CFG}.tmp

	# if this is Windows (e.g. under cygwin) need to convert paths over before passing to java interpreter
	#
	# NOTE: consider changing this to use sed(1) in particular 
	# 	if standardising on cygwin for windows environments
	#
	if [ $OSTYPE != "Linux" ] && [ -e /usr/bin/cygpath ] ; then
		CFGTEMPL=`cygpath -w $CFGTEMPL`
		CFGTMP=`cygpath -w $CFGTMP`
		CFG=`cygpath -w $CFG`
	fi

	try "cp $CFGTEMPL $CFG"
	try "cp $CFG ${CFGTMP}"
	# try "${SED2} $CFGTEMPL $CFG __INSTALLDIR__ ${INSTALLDIR}"
	# try "cp $CFG ${CFGTMP}"

	try "rm ${CFGTMP}"
	log "customised silent $OPERATION response file $CFG ok" 

	# return CFG
}


# subroutine runCheckScripts:	Runs the pre-install check scripts associated with this PRODUCT
#
. $INSTALLDIR_BLD/db2rtcl/log.bash
. $INSTALLDIR_BLD/db2rtcl/try.bash

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


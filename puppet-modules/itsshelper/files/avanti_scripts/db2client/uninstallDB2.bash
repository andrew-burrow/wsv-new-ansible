# subroutine: uninstallDB2
#
. $INSTALLDIR_BLD/db2rtcl/log.bash
. $INSTALLDIR_BLD/db2rtcl/try.bash

uninstallDB2()
{
	OPERATION=$1
	PRODUCT=$2

	# drop existing instance
	#
	try "cd ${INSTALLDIR}${PS}instance"
	try "${INSTALLDIR}${PS}instance${PS}db2idrop ${DB2INSTANCE}"

	# expand into DB2 eassembly where the uninstall command is
	#
	expandIntoDB2

	# uninstall product binary
	#
	try "./db2_deinstall${SFXE} -a -b ${INSTALLDIR} -l ${SPOOLDIR_LOG}${PS}${OPERATION}_${PRODUCT}.log"

	# remove instance user
	#
	try "userdel ${DB2INSTANCE}"

	# remove global .profile
	#
	try "rm -f ${PS}etc${PS}profile.d${PS}db2envsetup${SFXB}"
}


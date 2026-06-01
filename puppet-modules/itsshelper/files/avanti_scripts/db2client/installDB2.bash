# subroutine: installDB2
#
. $INSTALLDIR_BLD/db2rtcl/log.bash
. $INSTALLDIR_BLD/db2rtcl/try.bash
. $INSTALLDIR_BLD/db2rtcl/expandIntoDB2.bash

installDB2()
{
	OPERATION=$1
	PRODUCT=$2

	# expand into DB2 eassembly where the install command is
	#
	expandIntoDB2

	# perform the silent install
	#
	# NOTE: this will also create and instance $DB2INSTANCE and associated user
	#       which is important to rememember during the uninstall procedure
	#
	try "./db2setup${SFXE} -r $CFG -l ${SPOOLDIR_LOG}${PS}${OPERATION}_${PRODUCT}.log"

	# populate the global .profile augmentation
	#
	try "cp -p ${INSTALLDIR_BLD}${PS}db2rtcl${PS}db2envsetup${SFXB} ${PS}etc${PS}profile.d"
}

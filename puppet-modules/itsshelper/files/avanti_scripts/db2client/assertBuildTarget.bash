# subroutine assertBuildTarget:	Creates a build artefact post successfull component install
#
. $INSTALLDIR_BLD/db2rtcl/log.bash
. $INSTALLDIR_BLD/db2rtcl/try.bash

assertBuildTarget()
{
	OPERATION=$1
        PRODUCT=$2
	S='assertBuildTarget'

	SHCLOG=$SHCDIR${PS}${OPERATION}_${PRODUCT}
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
		'IHS'|'PLG'|'WAS'|'SDK')
			VERIFYCMD=${INSTALLDIR}${PS}bin${PS}versionInfo${SFXB}
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
			VERIFYCMD="${INSTALLDIR}${PS}tools${PS}imcl${SFXE}"
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
			VERIFYCMD="${INSTALLDIR}${PS}tlmagent${SFXE}"
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
			VERIFYCMD=`which dspmqver`
			if [ -z $VERIFYCMD ] ; then
				log "$S - warning: no dspmqver command was found for $PRODUCT"
				VERIFYCMD=""
			else
				log "$S - performing: $VERIFYCMD > $SHCLOG"
				$VERIFYCMD > $SHCLOG || echo "$S failed to perform \"$VERIFYCMD\""
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
			case $PRODUCT in
			'SDK')
					PRODUCT_ID=IBMJAVA7
					VERIFYCMD="awk '{a[NR]=\$0}\$0~/^ID.*$PRODUCT_ID$/ {print a[NR-1]}' $SHCLOG | cut -d' ' -f2- | sed -e 's/^ *//' -e 's/ *$//' "
					eval VERSINFO=\$\($VERIFYCMD\)
					;;
			'WAS')
					PRODUCT_ID=ND
					VERIFYCMD="awk '{a[NR]=\$0}\$0~/^ID.*$PRODUCT_ID$/ {print a[NR-1]}' $SHCLOG | cut -d' ' -f2- | sed -e 's/^ *//' -e 's/ *$//' "
					eval VERSINFO=\$\($VERIFYCMD\)
					;;
			*)
					VERSINFO=`cat $SHCLOG | egrep "^Version[:]*\s+[[:digit:]]" | awk '{print $2}'`
					;;
			esac
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
		for file in `ls ${SHCDIR}/*_${PRODUCT}_*` ; do
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


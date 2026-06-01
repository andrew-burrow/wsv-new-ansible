# declare all other vars based on properties declared vars or defaultVars()
#
declareVars()
{
    CELLNAME=${HOSTNAME}Cell01				# WAS Cell Name - for singleNodeTopology only
    NODENAME=${HOSTNAME}Node01				# WAS Node Name - for singleNodeTopology only
    PROFILEROOT=${INSTALLDIR_WAS}${PS}profiles		# WAS profiles root directory
    
    SCRIPTROOT=$CONFIGROOT				# location of generated run level 3 scripts
    
    SPOOLDIR_IM=${SPOOLROOT}${PS}staging		# spool for Installation Manager 
    SPOOLDIR_STG=${SPOOLROOT}${PS}staging		# spool for Installation Manager (alias)
    SPOOLDIR_ECD=${SPOOLROOT}${PS}eclipseCache		#   "    "        "         "
    SPOOLDIR_LOG=${SPOOLROOT}${PS}logs			# spool for install / build script logs
    SPOOLDIR_IHS=${SPOOLROOT}${PS}HTTPServer		# spool for HTTPServer logs etc.
    SPOOLDIR_PLG=${SPOOLROOT}${PS}Plugins		# spool for Plugin logs
	SPOOLDIR_SDK=${SPOOLROOT}${PS}sdk		# spool for sdk logs
    SPOOLDIR_WAS=${SPOOLROOT}${PS}WebSphere${PS}AppServer	# spool for WAS profiles logs
    SPOOLDIR_MQM=/var/mqm					# spool for MQM queue managers/transaction logs/utils
    
    TECHGROUP_DB2=$TECHUSER_DB2		# postinstall DB2 group to be applied to installed binaries
    TECHGROUP_IM=$TECHUSER_IM		# postinstall IM group to be applied to installed binaries
    TECHGROUP_IHS=$TECHUSER_IHS		# postinstall IHS group to be applied to installed binaries
    TECHGROUP_PLG=$TECHUSER_PLG		# postinstall PLG group to be applied to installed binaries
    TECHGROUP_WAS=$TECHUSER_WAS		# postinstall WAS group to be applied to installed binaries
	TECHGROUP_SDK=$TECHUSER_SDK		# postinstall SDK group to be applied to installed binaries
    TECHGROUP_MQM=$TECHUSER_MQM		# postinstall MQM group to be applied to installed binaries
    
    TEMPLATEROOT=${INSTALLDIR_WAS}${PS}profileTemplates
    
    UTILS_MQM=${INSTALLDIR_BLD}${PS}utils${PS}mq${PS}mqTools.tar	# utilities to be expanded into mqm home
    
    
    # java utils
    #
    jopts="-Dlog4j.defaultInitOverride=false -Dlog4j.configuration=${JAVALOG4JCFG}"
	# cp=$INSTALLDIR_BLD/lib/java/log4j-1.2.17.jar:$INSTALLDIR_BLD/lib/java/SED.jar
    cl=org.apache.lenya.util.SED2
    SED2="${JAVA} ${jopts} -cp ${JAVACP} $cl "		# append 3 args to this call e.g.
							#   ${SED2} $CFG __INSTALLDIR__ ${INSTALLDIR}
    RMSC="${JAVA} -jar ${JAVAJAR} "			# RMScopes tool
}


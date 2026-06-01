# declareDefaults	- declare all default vars in case not sourced from props file
#
declareDefaults()
{
    CHMODMASK=750					# postinstall mask to be applied to installed binaries
    
    CONFIGROOT=/opt/IBM/etc				# root of where static config files and scripts are generated
    
    DB2INSTANCE=db2iadm1				# DB2 Client Instance name / User name

    # location of jython resources to deploy a simple sample app
    #
    DEPLOY_PROPS_TEMPLATE=/opt/IBM/build/utils/was/testApp/superSnoop/config/template.basicSetup.properties
    DEPLOY_SCRIPT_TEMPLATE=/opt/IBM/build/utils/was/testApp/superSnoop/template.deployEarFile.py
    
    EASSEMBLY_DB2="v9.7fp6_linuxx64_rtcl"		# DB2 Client Core EAssembly name prefix
    EASSEMBLY_IM="WAS8_InstallMgr_CZM8XML.zip"		# Installation Manager E-Assembly (Unix/Windows zip file)
    EASSEMBLY_LMT="ILMT-TAD4D-agent-7.2.2-linux-x86.rpm"	# binary core eAssembly name for LMT Agent
    IGNOREERRORS=false					# fail on an error occuring - used by try() subroutine
    
    INSTALLROOT=/opt/IBM				# common target root for binary install
							# NOTE: this is a local var and has no PROPSFILE equivalent
   
    INSTALLBV_DB2=9.7.0.6				# Base Version of DB2 Client
    INSTALLFS_DB2=/opt                                  # installation target filesytem for DB2 Client
    INSTALLDIR_DB2=$INSTALLFS_DB2/config/db2client	# installation target directory for DB2 Client
    INSTALLFP_DB2=9.7.0.6				# DB2 fix pack version
    INSTALLFS_DB2_SIZE=20000				# min. size in M of DB2 client
   
    INSTALLBV_IHS=8.0.0.0				# Base Version of IBM HTTP Server (IHS)
    INSTALLDIR_IHS=$INSTALLFS_IHS/IBM/HTTPServer	# installation target directory for IHS
    INSTALLFP_IHS=8.0.0.4				# IHS fix pack version
    INSTALLFS_IHS=/opt					# installation target filesystem for IHS
    INSTALLFS_IHS_SIZE=5000				# min. size in M of IHS
   
    INSTALLBV_IM=1.4.3.1				# Base Version of IM (Installation Manager)
    INSTALLDIR_IM=$INSTALLFS_IM/IBM/InstallationManager/eclipse	# installation target directory for IM
    INSTALLFP_IM=1.4.3.1				# IM fix pack version
    INSTALLFS_IM=/opt					# installation target filesytem for IM
    INSTALLFS_IM_SIZE=2000				# min. size in M of IM 
   
    INSTALLBV_LMT=7.2.2.0				# Base Version of License Management Tool Agent (LMT)
    INSTALLDIR_LMT=$INSTALLFS_LMT/tivoli		# installation target directory for LMT
    INSTALLFP_LMT=7.2.2.0				# LMT fix pack version
    INSTALLFS_LMT=/opt					# installation target filesystem for LMT
    INSTALLFS_LMT_SIZE=400				# min. size in M of LMT

    INSTALLBV_MQM=7.0.0.1				# Base Version of IBM WebSphere MQ Series Server (MQM)
    INSTALLDIR_MQM=/opt/mqm				# installation target directory for MQ Series
							# IMPORTANT: cannot alter INSTALLDIR_MQM
    INSTALLFP_MQM=7.0.1.9				# MQM fixpack
    INSTALLFS_MQM=/opt					# target filesystem
    INSTALLFS_MQM_SIZE=2000				# min. size in M of MQM

    INSTALLBV_PLG=8.0.0.0				# Base Version of WAS plugins for IHS
    INSTALLDIR_PLG=$INSTALLFS_PLG/IBM/Plugins		# installation target directory for WebSphere Plugins (PLG)
    INSTALLFP_PLG=8.0.0.4				# PLG fix pack version
    INSTALLFS_PLG=/opt					# installation target filesystem for WebSphere Plugins (PLG)
    INSTALLFS_PLG_SIZE=2000				# min. size in M of PLG
   
    INSTALLBV_WAS=8.0.0.0				# Base Version of WebSphere Application Server Network Deployment (WAS)
    INSTALLDIR_WAS=$INSTALLFS_WAS/IBM/WebSphere/AppServer	# installation target directory for WAS
    INSTALLBV_WAS=8.0.0.4				# WAS fix pack version
    INSTALLFS_WAS=/opt					# installation target filesystem for WAS
    INSTALLFS_WAS_SIZE=30000				# min. size in M of WAS
   
    JAVA=/usr/bin/java					# java home
    JAVACP=$INSTALLDIR_BLD/db2rtcl/log4j-1.2.17.jar:$INSTALLDIR_BLD/db2rtcl/SED.jar	# java classpath to reference class SED2
    JAVAJAR=$INSTALLDIR_BLD/utils/RMScopes/bin/RMScopes-1.0.jar			# RMScopes utility JAR location
    JAVALOG4JCFG=file://${INSTALLDIR_BLD}/db2rtcl/log4j.properties			# Log4J properties

    LMTSERVER=linvm120.services.workcover.vic.gov.au	# IBM License Management Tool Server location 

    
    REPOROOT=$INSTALLROOT/software				# IBM eAssemblies file system (for binary install)
    REPO_CORE_DB2=$REPOROOT${PS}db2${PS}client			# post expansion location of eAssembly - core DB2 Client
    REPO_CORE_IM=$REPOROOT${PS}was8x${PS}InstallationManager	# post expansion location of eAssembly - core Installation Manager
    REPO_CORE_IHS=$REPOROOT${PS}was8x${PS}Supplements${PS}base${PS}disk1	# post expansion location of eAssembly - core IBM HTTP Server
    REPO_CORE_LMT=$REPOROOT${PS}ILMT${PS}Linux					# location of zip archive of LMT rpm's
    REPO_CORE_PLG=$REPOROOT${PS}was8x${PS}Supplements${PS}base${PS}disk1	# post expansion location of eAssembly - core Plugins
    REPO_CORE_WAS=$REPOROOT${PS}was8x${PS}WebSphere${PS}base${PS}disk1	# post expansion location of eAssembly - core WAS ND
    REPO_CORE_MQM=$REPOROOT${PS}mqm7x${PS}MQv7.0${PS}base		# post expansion location of eAssembly - core MQ Series
    REPO_FIXP_IM=$REPOROOT${PS}was8x${PS}InstallationManager	# post expansion location of eAssembly - fixpack Installation Manager
    REPO_FIXP_IHS=$REPOROOT${PS}was8x${PS}Supplements${PS}maint		# location of eAssembly patch subdirs - fixpack IBM HTTP Server
    REPO_FIXP_LMT=$REPOROOT${PS}ILMT${PS}Linux				# location of zip archive of LMT rpm's
    REPO_FIXP_PLG=$REPOROOT${PS}was8x${PS}Supplements${PS}maint		# location of eAssembly patch subdirs fixpack Plugins
    REPO_FIXP_WAS=$REPOROOT${PS}was8x${PS}WebSphere${PS}maint		# location of eAssembly patch subdirs fixpack WAS ND
    REPO_FIXP_MQM=$REPOROOT${PS}mqm7x${PS}MQv7.0${PS}maint		# location of eAssembly patch subdirs fixpack MQ Series
   
    RETRYCOUNT=10					# max addNode attempts
    RETRYTIME=30					# addNode() retry in case dmgr is busy 
    #OSNAME="Linux"					# platform type
    OSARCH="64"						# base architecture expected (32/64 bit)
    OSVERS="6"						# base OS version expected
   
    PORTSFILE_TEMPLATE_DMGR=$INSTALLDIR_BLD/cfg/dmgr_management_default_portdef.props
    PORTSFILE_TEMPLATE_JMGR=$INSTALLDIR_BLD/cfg/jmgr_management_default_portdef.props
    PORTSFILE_TEMPLATE_NODE=$INSTALLDIR_BLD/cfg/node_managed_default_portdef.props
    
    PROCSTRING_IHS=httpd				# process string identifier for IHS
    PROCSTRING_MQM=mqm					# process string identifier for MQM
    PROCSTRING_WAS=${INSTALLDIR_WAS}/java/bin/java	# process string identifier for WAS
    
    PROFILEAPPL=AppSrv01				# WAS profile name for Application Server
    PROFILEDMGR=Dmgr01					# WAS profile name for Deployment Manager
    PROFILEJMGR=Jmgr01					# WAS profile name for Job Manager

    RMSCOPESPROPS=$INSTALLDIR_BLD/cfg/RMScopes.properties	# RMScopes properties containing location of Topology<ENV>.xls file

    SERVERNAME=server1					# WAS Application Server name
    SOAPPORT=8879					# WAS SOAP Port listener
    SOAPLOGINUSERID=wasadmin				# WAS SOAP Login User
    SOAPLOGINPASSWORD=password321			# WAS SOAP Login Password - NOTE: this should be overridden!!
    
    SPOOLROOT=/var/spool/IBM				# Spool root of all IBM installed products
    
    TECHUSER_IM=$SOAPLOGINUSERID				# postinstall IM owner to be applied to installed binaries
    TECHUSER_DB2=${DB2INSTANCE}				# postinstall DB2 owner to be applied to installed binaries
    TECHUSER_IHS=$SOAPLOGINUSERID				# postinstall IHS owner to be applied to installed binaries
    TECHUSER_PLG=$SOAPLOGINUSERID				# postinstall PLG owner to be applied to installed binaries
    TECHUSER_WAS=$SOAPLOGINUSERID				# postinstall WAS owner to be applied to installed binaries
    TECHUSER_MQM=mqm					# postinstall MQM owner to be applied to installed binaries

    TOPOLOGYCONFIG=$INSTALLDIR_BLD/cfg/TopologyDEV.xls	# RMScopes topology definition Excel (*.xls) file

    UNINSTALL_SCRIPT_TEMPLATE=$INSTALLDIR_BLD/utils/was/testApp/superSnoop/template.uninstallApp.py	# jython sample app uninstall

}

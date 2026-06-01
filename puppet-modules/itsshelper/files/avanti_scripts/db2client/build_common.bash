#!/bin/bash

#
# program:	build_common.bash
# author:	Boris Carli, WorkSafe
# date:		Oct 23 2012
# pupose:	Common environment / libs file for related shell scripts
# usage:	Source this file from a main script - for an example see
#		"install_IBMPRODUCT.bash".
# customisation:Alter the global vars section as required.
#		It is envisaged to keep this constant for the WorkSafe SOE RHEL6
#		otherwise it might make more sense to move the vars into
#		into a properties file if customisation changes are frequent.
# IMPORTANT: 	This file is only to be sourced within a script.
#
# to-do:	
#		1. Alter check script logic to simply look for check*_<PRODUCT>.[ba]sh scripts
#		rather than using a fixed set of check class types.
#
# repository:	resources added to svn on 15 January 2013 at location:
#
#		http://dev1bld1.dev.tac/svn/ITSS_Environment_Services/avanti-config/templates/config/wasscripts/build
#
#
# history:
#
# Patch-Level	Date
#
# 1.0.0.34	Feb 20 2013   - renamed to build_common.bash; refactored all subroutines into
#				specific libraries under ../lib/bash/<category>/<libName>
#
# 1.0.0.33	Feb 08 2013   - createLinuxService() function added to create a 
#				Linux service for any component that has a 
#				LINUXSERVICE_<PRODUCT> entry in the build_properties_Linux.ini
#				Used primarily for IHS as the WASService function is used
#				to add a service for Dmgr or NodeAgent accordingly.
#
# 1.0.0.33	Feb 06 2013   - addNode() enhanced with retry logic in case dmgr
#				is busy wiht another parallel federation request
#				(as distinct from not being available which is 
#				handled by waitForDmgr()); also enhanced RMSCopes
#				logic included with Topology for SVT.
#
# 1.0.0.32	Jan 24 2013   - createDmgr(), createNode(), manageDmgr() manageNode()
#				functions altered with overload parameters to excplicitly
#				control nodes; also implemented getTopologyData() and
#				added generatePortsFileFromTemplate() to facilitate
#				multiple node support.
#
# 1.0.0.31	Jan 17 2013   - waitForDmgr() and getTopologyData() routines added
#				to facilitate the new createProfile.bash script which
#				will selectively create the profile(s) intended for the
#				server being installed based on the topology configuration.
#
# 1.0.0.30	Jan 15 2013   - doPrompt() routine and logic added to "createDmgr()" and
#				"createNode()" to prompt for Windows Service Account
#				userid and password
# 1.0.0.29	Jan  8 2013   - assessBuildState altered so that MQM and DB2 do not have
#				dependencies on InstallationManager; manage_MQM_template.bash
#				altered so that all mqm specific commands are performed as
#				the mqm user.
#

# determine root directory of this script to find other resources
#
VERSION=1.0.0.35
VERDATE=21022013

PROG=`basename $0 .bash`        # get short name of script
ROOTDIR=`dirname $0`            # get dirname to this script
OSNAME=`uname -s`		# get operating system name

if [ $OSNAME = "Linux" ] ; then	# determine suffixes for programs
    PS='/'
    SFXB='.sh'
    SFXE=''
    SFXL='.so'
    OSTYPE="Linux"
else
    PS='\\'
    SFXB='.bat'
    SFXE='.exe'
    SFXL='.dll'
    OSTYPE="Windows"
    OSNAME="CYGWIN_NT"
fi

# other constants
#

# determine build root
#
if [ $ROOTDIR = '.' ] ; then
    ROOTDIR=`pwd`
fi

# this host
#
HOSTNAME=`hostname`					# this server - used by other vars further down

# IMPORT SUBROUTINES
#
INSTALLDIR_BLD=`dirname $ROOTDIR`			# base build directory location
. $INSTALLDIR_BLD/db2rtcl/checkFS.bash               
. $INSTALLDIR_BLD/db2rtcl/exitOnRc.bash    
. $INSTALLDIR_BLD/db2rtcl/log.bash              
. $INSTALLDIR_BLD/db2rtcl/sysCheck.bash         
. $INSTALLDIR_BLD/db2rtcl/try.bash
. $INSTALLDIR_BLD/db2rtcl/declareDefaults.bash 
. $INSTALLDIR_BLD/db2rtcl/declareVars.bash  
. $INSTALLDIR_BLD/db2rtcl/initLogs.bash  
. $INSTALLDIR_BLD/db2rtcl/initVars.bash


: <<'END'
declaring main
END

# main
#

# declare default vars - these can be overriden from the PROPSFILE
#
declareDefaults

# source property file declarations to override defaults
#
PROPSFILE=${INSTALLDIR_BLD}/cfg/build_properties_${OSTYPE}.ini

if [ -f $PROPSFILE ] ; then
	log "$0: declaring PROPSFILE \"$PROPSFILE\" properties"
	# while read -r line; do declare $line; done <$PROPSFILE
	while read -r line; do declare $line; eval $line; done <$PROPSFILE
else
	log "$0: WARNING no PROPSFILE \"$PROPSFILE\" to source, using default values"
fi

# declare vars requiring above sourced constants
#
declareVars

# initialise logging
#
initLogs $0 $OSNAME

# OS sanity check
#
sysCheck $0 $OSNAME

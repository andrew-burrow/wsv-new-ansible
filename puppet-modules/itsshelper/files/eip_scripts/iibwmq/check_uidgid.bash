#!/bin/bash

#
# program:      check_uidgid.bash
# author:       Boris Carli, WorkSafe
# date:         January 7 2013
# purpose:      Checks existence of technical user and group
#

TECHUSER=$1
TECHGROUP=$2

SAMPLE="adduser --base-dir /opt/IBM/WebSphere --comment \"WebSphere Administrator Functional User\" --no-create-home --uid 500 --user-group wasadmin"

printUsage()
{
	echo "$0 <techuser> <techgroup>"
	echo "If the script failed consider adding the missing user with the adduser command, e.g."
	echo "$SAMPLE"
	exit 1
}

OSNAME=`uname -s`               # get operating system name
if [ $OSNAME != "Linux" ] ; then
	echo "$0 - check script is ignored for non Linux platforms"
	exit 0
fi
if [ "X" != "X"$TECHUSER ] ; then
	if [ "mqm" = $TECHUSER -o "db2iadm1" = $TECHUSER ] ; then
		echo "$0 - check script is ignored for user $TECHUSER"
		exit 0
	fi
fi


rc=0
id $TECHUSER
rc=$?
if [ $rc != 0 ] ; then
        echo "$0 - failed tech user check on $TECHUSER"
	printUsage
fi

groups $TECHGROUP
rc=$?
if [ $rc != 0 ] ; then
        echo "$0 - failed tech group check on $TECHGROUP"
	printUsage
fi


#!/bin/bash

#
# program:	verify_IIB.bash
# author:	Neil Casey, WorkSafe, Apr 13 2015
# purpose:	Validate an IIB installation
#
printusage()
{
	echo "usage: $0"
	echo "  Environment veriable ENV is the installed environment name"
	echo "  It must be available in the environment prior to invocation"
}

if [ -z "$ENV" ] ; then
	printusage
	exit 1
fi
env=${ENV,,} # lower case
SPATH=/opt/$env/iib/	# path to iib installation
if [ ! -h $SPATH ] ; then
	printusage
	exit 1
fi

VERIFYCMD=/opt/${env}/iib/iib
VERIFYOPTS="verify all"
if [ -z $VERIFYCMD ] ; then
	log "$S - warning: no iib command was found for $PRODUCT"
	VERIFYCMD=""
else
	log "$S - performing: $VERIFYCMD
	$VERIFYCMD $VERIFYOPTS || echo "$S failed to perform \"$VERIFYCMD\""
fi


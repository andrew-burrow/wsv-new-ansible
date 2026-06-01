#!/bin/bash

#
# program:	check_maxproc_MQM.bash
# author:	Boris Carli, WorkSafe
# date:		November 1 2012
# purpose:	Checks on maximum number of procs for mqm
#
rc=0			# script exits with this return code
diffs=0			# keep track of differences 

echo "-----------------------------------------"
echo "Checking nproc for user mqm ...."
np=`su - mqm -c "ulimit -u"`
if [[ $np == "" ]] ; then
	echo "could not identify ulimit on user mqm - please ensure user exists after MQ install"
else
	if [[ $np -ge 4096 ]] ; then
		echo "ulimit -u \"nproc\" for user mqm is ok"
	else
		echo "warning: nproc for user mqm should be at least 4096 - it is currently $np"
	fi
fi
echo "-----------------------------------------"

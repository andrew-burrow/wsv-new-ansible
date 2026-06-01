#!/bin/bash

#
# program:	check_mof_MQM.bash
# author:	Boris Carli, WorkSafe
# date:		October 31 2012
# purpose:	Checks on max open files needed for MQM v7 on RHEL 6.
#
printChangeMessage()
{
	tab=$1
	cur=$2
	min=$3
	echo "${tab}WARNING - Changes are required"
	echo "${tab}	Please alter the minimum value for $i to $min as follows:"
	echo "${tab}	open the file /etc/sysctl.conf with a text editor"
	echo "${tab}	then change the value for attribute \"$i\" "
	echo "${tab}		from \"$cur\""
	echo "${tab}		to   \"$min\""
	echo "${tab}	save and close the file"
	echo "${tab}	Load these system values immediately by running the command \"sysctl -p\""
	echo "${tab}	or alternately you can reboot the system"
	echo ""
}

rc=0			# script exits with this return code
diffs=0			# keep track of differences 

echo "Performing sysctl check on fs.file-max and fs.file-nr:"
/sbin/sysctl fs.file-max
/sbin/sysctl fs.file-nr
echo "-----------------------------------------"
echo "Checking ulimit for user mqm ...."
su - mqm -c "ulimit -n"
if [ $? != 0 ] ; then
	echo "could not identify ulimit on user mqm - please ensure user exists after MQ install"
fi
echo "-----------------------------------------"
LIMSFILE=/etc/security/limits.conf
LIMSDIR=/etc/security/limits.d
LIMSDIRFILES=$(ls $LIMSDIR/*)
valMofHard="mqm - nofile 10240"
valMofSoft="mqm - nofile 10240"
valMpHard="mqm - nproc 4096"
valMpSoft="mqm - nproc 4096"
for check in "${valMofHard}" "${valMofSoft}" "${valMpHard}" "${valMpSoft}";do
{
echo "Check: $check"
user=$(echo $check | awk '{ print $1 }')
hard_soft=$(echo $check | awk '{ print $2 }')
limit_name=$(echo $check | awk '{ print $3 }')
limit_value=$(echo $check | awk '{ print $4 }')
echo "Checking ${hard_soft} limits for ${limit_name} for user ${user} in $LIMSFILE and $LIMSDIR ..."
# Generate regular expression. Line starts with mqm ($1), then must contain 
# each of the other elements, separated by any amount of whitespace
checkregex=$(echo ${check} | awk '{ print "^" $1 "[[:blank:]]*" $2 "[[:blank:]]*" $3 "[[:blank:]]*" $4 }')
grep -E "${checkregex}" $LIMSFILE $LIMSDIRFILES
if [ $? != 0 ] ; then
	echo "No ${hard_soft} limits set for ${limit_name} for user ${user}."
	echo "Please ensure to set recommended values by editing the $LIMSFILE"
	echo "or a $LIMSDIR file and including the following line:"
	echo ${check}
	rc=1
fi
echo "-----------------------------------------"
}
done

if [ $rc -ne 0 ]; then
	exit $rc
fi
echo "-----------------------------------------"

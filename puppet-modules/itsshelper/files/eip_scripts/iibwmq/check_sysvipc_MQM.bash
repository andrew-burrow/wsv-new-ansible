#!/bin/bash

#
# program:	checkSysVIPC.bash
# author:	Boris Carli, WorkSafe
# date:		October 31 2012
# purpose:	Check on System V IPC Settingsas on RHEL6 for MQv7 as per InfoCentre ref:
# 		http://publib.boulder.ibm.com/infocenter/wmqv7/v7r0/index.jsp?topic=%2Fcom.ibm.mq.amq1ac.doc%2Flq10120_.htm
# 		Program checks to see that System V IPC values for MQ should be set to minimum as shown below
#

setKernelParm()
{
name=$1
shift
value="$*"
ctl_file=/etc/sysctl.conf

if `grep ^${name} $ctl_file 1>/dev/null 2>&1` ;then
	echo "Found $name in $ctl_file"
	sed -i "s/^${name}.*/${name} = ${value}/" $ctl_file
else
	echo "Adding ${name} = ${value} to $ctl_file"
	echo "#Added for MQ installation - $(date)" >> $ctl_file
	echo "${name} = ${value}" >> $ctl_file
fi

sysctl -p
}



printChangeMessage()
{
	tab=$1
	nam=$2
	cur=$3
	min=$4
	echo "${tab}WARNING - Changes are required"
	echo "${tab}	The value for attribute \"$nam\" is being changed"
	echo "${tab}		from \"$cur\""
	echo "${tab}		to   \"$min\""
	echo "${tab}	Loading these system values immediately by running the command \"sysctl -p\""
	echo ""
}

rc=0			# script exits with this return code
diffs=0			# keep track of differences 

# define kernel attributes in sequence to be tested
#
sysVIPCnames=(
	kernel.msgmni
	kernel.shmmni
	kernel.shmall
	kernel.shmmax
	fs.file-max
	net.ipv4.tcp_keepalive_time
)

sysVIPCnames2=(
	kernel.sem
)

# ${CHECKSCRIPTS[@]}

# define minimum kernel values required
#
kernel_msgmni=1024
kernel_shmmni=4096
kernel_shmall=2097152
kernel_shmmax=268435456
kernel_sem="500 256000 250 1024"
fs_file_max=524288
net_ipv4_tcp_keepalive_time=300

# fetch current kernel values
#
current_kernel_msgmni=`cat /proc/sys/kernel/msgmni`
current_kernel_shmmni=`cat /proc/sys/kernel/shmmni`
current_kernel_shmall=`cat /proc/sys/kernel/shmall`
current_kernel_shmmax=`cat /proc/sys/kernel/shmmax`
current_kernel_sem=`cat /proc/sys/kernel/sem`
current_fs_file_max=`cat /proc/sys/fs/file-max`
current_net_ipv4_tcp_keepalive_time=`cat /proc/sys/net/ipv4/tcp_keepalive_time`

# compare the singular numeric attributes
#
j=0
for i in kernel_msgmni kernel_shmmni kernel_shmall kernel_shmmax fs_file_max net_ipv4_tcp_keepalive_time ; do
	eval min=\$$i 
	cur=current_${i}
	eval cur=\$$cur
	name=${sysVIPCnames[$j]}
	# echo "examining $i => current value $cur minimum value $min"
	echo "examining $name => current values $cur minimum values $min"
	if [ $cur -ge $min ] ; then 
		echo "	$cur >= $min so all good"
	else 
		printChangeMessage "	" $name $cur $min
		setKernelParm $name $min
		diffs=$(($diffs+1))
		#rc=1
	fi
	j=$(($j+1))
done

# compare the array numeric attributes
#
j=0
for i in kernel_sem ; do
	eval mins=\$$i 
	curs=current_${i}
	eval curs=\$$curs
	name=${sysVIPCnames2[$j]}
	# echo "examining $i => current values $curs minimum values $mins"
	echo "examining $name => current values $curs minimum values $mins"
	set -- junk $curs
	changes=0
	new_kernel_sem=""
	for min in $mins ; do
		shift
		cur=$1
		if [ $cur -ge $min ] ; then
			echo "	$cur >= $min so all good"
			new_kernel_sem="$new_kernel_sem $cur"
		else
			echo "	$cur < $min so change required"
			changes=$[$changes+1]
			new_kernel_sem="$new_kernel_sem $min"
		fi
	done
	
	if [ $changes -gt 0 ] ; then
		echo "	total of $changes differences detected"
		tab="		"
		printChangeMessage "$tab" "$name" "$curs" "$mins"
		#rc=1
		diffs=$(($diffs+1))
		setKernelParm $name $new_kernel_sem
	fi
	j=$(($j+1))
done
echo "A total of $diffs different attributes were found; exiting with rc=$rc"
exit $rc

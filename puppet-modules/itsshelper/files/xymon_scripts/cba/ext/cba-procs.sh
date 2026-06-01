#!/bin/sh
# cba-procs.sh
#
# MQ processes monitoring script - JR 
#
# Based on $BBHOME/bin/bb-procs.sh V1.9a, with initialisation
# section from $BBHOME/bin/bb-local.sh V1.9a
#
# Uses $PROCTAB for process masks - see section "Constants"
#
####################
# Initialisation - from bb-local.sh
###################
#
# echo "***** BBHOME IS SET TO $BBHOME"
# echo "***** BBTMP IS SET TO $BBTMP"

if test ! "$BBTMP"                      # GET DEFINITIONS IF NEEDED
then
	 # echo "*** LOADING BBDEF ***"
        . $BBHOME/etc/bbdef.sh          # INCLUDE STANDARD DEFINITIONS
fi

# Setup the name of the local host
# Save a version of the machine name with '.' instead of ',', if any are there
MACHINEDOTS=`echo $MACHINE | $SED 's/,/\./g'`
if [ "$FQDN" != "TRUE" ]
then
	OLDIFS=$IFS
	IFS='.'
	set $MACHINEDOTS >/dev/null
	IFS=$OLDIFS
	MACHINEMASK="${1}"
else
	MACHINEMASK="${MACHINEDOTS}"
fi
export MACHINEDOTS MACHINEMASK

BBCOMBOID="$$"
export BBCOMBOID

$BBHOME/bin/bb-combo.sh start

####################
# Constants
####################

TEST_NAME=procs-cba	# this is the title of the column on the BB display
			# use "procs-myname" so that the new column is displayed
			# after the standard bb "procs" column
PROCTAB=${BBHOME}/ext/cba-proctab

####################
# Main
####################

$PS > $BBTMP/bb.$$			# GET A PS LISTING

if test ! "$MACHINEDOTS"		# THIS SHOULD ALREADY BE SET...
then
	# Setup the name of the local host
	# Save a version of the machine name with '.' 
	# instead of ',', if any are there
	MACHINEDOTS=`echo $MACHINE | $SED 's/,/\./g'`
	if [ "$FQDN" != "TRUE" ]
	then
		OLDIFS=$IFS
		IFS='.'
		set $MACHINEDOTS >/dev/null
		IFS=$OLDIFS
		MACHINEMASK="${1}"
	else
		MACHINEMASK="${MACHINEDOTS}"
	fi
	export MACHINEDOTS MACHINEMASK
fi

#=====================================================================
# PROCESSES THAT MUST EXIST
#=====================================================================
#
# echo "*** PROCESSES TEST ***"

GREENLINES=""
YELLOWLINES=""
REDLINES=""
STATLINE="No processes to check"
COLOR="green"

# if $PROCTAB override defaults from bbdef.sh

if [ -f "$PROCTAB" ]
then
	# a line can start with
	# :....
	#  :....
	# localhost:...
	# www:....
	# www.bb4.com:...
	#
	# All mask should allow for spaces/tabs before :
	# Grep for each mask
	$RM -f $BBTMP/BBPROCS.$$
	for mask in "[ 	]*:" "[ 	]*localhost[ 	]*:" "[ 	]*${MACHINEMASK}[ 	]*:" "[ 	]*${MACHINEMASK}\..*:"
	do
		# Save procs in FILE
		procsline=`$GREP "^${mask}" $PROCTAB >>$BBTMP/BBPROCS.$$ 2>/dev/null`
	done

	# IF any line matched then process
	if [ -s $BBTMP/BBPROCS.$$ ]
	then
		# Get rid of defaults
		PROCS=""
		PAGEPROC=""
		$RM -f $BBTMP/PROCS.$$
		$RM -f $BBTMP/PAGEPROC.$$
		cat $BBTMP/BBPROCS.$$ | $SORT -u |
		while read line
		do
			# If any ":" are found, force spaces around it to
			# make Solaris happy :(
			# Thanks to  Larry Parmelee <parmelee@CS.Cornell.EDU>
			line=`echo "$line" | $SED 's/:/ : /g'`
#			line=`echo "$line" | $SED 's/::/: :/g'`
			OLDIFS=$IFS
			IFS=':'
			set bogus $line
			shift
			IFS=$OLDIFS
			# Results are sent to a file because some shells go into a subshell
			# during a while preceded by a pipe such that variables set within
			# that while will not be visible after exiting the while. The {} should
			# not send it within a subshell but I'm wary (especially SUN & DIGITAL)
			echo " $2 " >> $BBTMP/PROCS.$$
			echo " $3 " >> $BBTMP/PAGEPROC.$$
		done
		PROCS=`$CAT $BBTMP/PROCS.$$`
		PAGEPROC=`$CAT $BBTMP/PAGEPROC.$$`
		$RM -f $BBTMP/PROCS.$$
		$RM -f $BBTMP/PAGEPROC.$$
	fi
	$RM -f $BBTMP/BBPROCS.$$
else
	PROCS=" ${PROCS} "
	PAGEPROC=" ${PAGEPROC} "
fi

#
# All this crap is to be able to handle processes specified
# with "":  snmmpd "syslogd -s" xntpd
# The string "syslogd -s" will be matched against the PS output
#
# The ' ' in the "" construct is replaced with '&_' temporarely
# until the string is actually used which is reverted back to ' '
#
# That's because a constrcut like "syslogd -s" in BBPROCS would
# appear as "syslogd and -s" in the for loop if no substitution
# was done:
# for proc in $BBPROCS  -> would become for proc in "syslogd -s"
# but proc instead of being "syslogd -s" there would be 2 proc
# iteration: one for "syslogd and the other -s"   
#
# Any clearer ?
#
# Must inverse !"   " to "!    " also

BBPROCS=`echo $PROCS $PAGEPROC | $SED 's/\![ 	]*"/"\!/g'`
if [ -n "$BBPROCS" ]
then
	OLDIFS=$IFS
	IFS='"'
	set " "$BBPROCS >/dev/null 2>&1
	IFS=$OLDIFS
	BBPROCS=""
	while [ $# -gt 0 ]
	do
		BBPROCS="$BBPROCS $1"
		if [ $# -gt 1 ]
		then
			BBPROCS="$BBPROCS "`echo $2 | $SED 's/ /\&_/g'`
			shift
		fi
		shift
	done
fi
	
for proc in $BBPROCS
do
	OLDIFS=$IFS
	IFS=";"
	set bogus $proc 2>/dev/null
	shift
	IFS=$OLDIFS
	proc=$1
	if [ "$#" -gt 1 ]
	then
		NUMPROCSEXPR=$2
	else
		NUMPROCSEXPR=999999
	fi
	
	proc=`echo "$proc" | $SED 's/\&_/ /g'`
	case $proc
	in
		*!* )
			proc=`echo "$proc" | $SED 's/!//g'`
			TESTREVERSED=TRUE
			NUMPROCSEXPR=0
			;;
		*)      
			TESTREVERSED=FALSE
			;;
	esac

	# No need to exclude grep from
	# process list
	# thanks to Paul Gluhosky
	# <paul.gluhosky@yale.edu>
	$GREP "$proc" $BBTMP/bb.$$ > $BBTMP/${TEST_NAME}.$$ 2>/dev/null
	if [ -s $BBTMP/${TEST_NAME}.$$ ]
	then
		NUMPROCS=`$CAT $BBTMP/${TEST_NAME}.$$ | $WC`
		NUMPROCS=`echo $NUMPROCS`
	else
		NUMPROCS=0
	fi
	$RM -f $BBTMP/${TEST_NAME}.$$
	RC=0
	ERRMSG1=""
	if [ "$NUMPROCS" -lt 1 ]
	then
		ERRMSG="not running"
	elif [ "$NUMPROCS" -eq 1 ]
	then
		ERRMSG="$NUMPROCS instance running"
	else
		ERRMSG="$NUMPROCS instances running"
	fi
	# Get the number of procs defined in the expression
	NUMPROCSVAL=`echo $NUMPROCSEXPR | $SED 's/[^0-9]//g'`
	case $NUMPROCSEXPR
	in
		999999 )
			if [ $NUMPROCS -eq 0 ]
			then
				RC=1
			fi
			ERRMSG1="at least 1"
			;;
		[0-9]* | \=[0-9]* )
			if [ $NUMPROCS -ne "$NUMPROCSVAL" ]
			then
				RC=1
			fi
			ERRMSG1="$NUMPROCSVAL"
			;;
		\<\=[0-9]* | \=\<[0-9]* )
			if [ $NUMPROCS -gt "$NUMPROCSVAL" ]
			then
				RC=1
			fi
			ERRMSG1="at most $NUMPROCSVAL"
			;;
		\>\=[0-9]* | \=\>[0-9]* )
			if [ $NUMPROCS -lt "$NUMPROCSVAL" ]
			then
				RC=1
			fi
			ERRMSG1="at least $NUMPROCSVAL"
			;;
		\>[0-9]* )
			if [ $NUMPROCS -le "$NUMPROCSVAL" ]
			then
				RC=1
			fi
			ERRMSG1="more than $NUMPROCSVAL"
			;;
		\<[0-9]* )
			if [ $NUMPROCS -ge "$NUMPROCSVAL" ]
			then
				RC=1
			fi
			ERRMSG1="less than $NUMPROCSVAL"
			;;
		* )
			;;
	esac
			
	case $NUMPROCSEXPR
	in
		0 )
			DISPEXPR="=0"
			;;
		999999 )
			DISPEXPR=">=1"
			;;
		* )
			DISPEXPR="(${NUMPROCSEXPR})"
			;;
	esac
	if test "$RC" != "0"
	then
		STATLINE="Some processes are in error"
		#
		# NOW SEE IF THIS IS A PROCESS WE SHOULD NOTIFY ON...
		#
		case $NUMPROCSEXPR
		in
			999999 | 0 )
				echo "$PAGEPROC" | $GREP "[ 	\"]$proc[ 	\"]" > /dev/null 2>&1
				;;
			* )
				echo "$PAGEPROC" | $GREP "[ 	\"]$proc;$NUMPROCSEXPR[ 	\"]" > /dev/null 2>&1
				;;
		esac
		if test "$?" = "0"
		then
			COLOR="red"
			REDLINES="&red $proc $DISPEXPR - $ERRMSG, requires ${ERRMSG1}
$REDLINES"
		else
			if test "$COLOR" != "red"	# WASN'T A PANIC
			then
				COLOR="yellow"		# SO JUST WARN
			fi
			YELLOWLINES="&yellow $proc $DISPEXPR - $ERRMSG, requires ${ERRMSG1}
$YELLOWLINES"
		fi	
	else
		if [ "$COLOR" = "green" ]
		then
			STATLINE="All processes are OK"
		fi
		GREENLINES="&green $proc $DISPEXPR - $ERRMSG 
$GREENLINES"
	fi
done

#
# NOW SEND THIS INFORMATION TO THE BIG BROTHER DISPLAY UNIT
#


$BBHOME/bin/bb-combo.sh add "status ${MACHINE}.${TEST_NAME} $COLOR `date` $STATLINE

${REDLINES}${YELLOWLINES}${GREENLINES}"

$BBHOME/bin/bb-combo.sh end

$RM -f $BBTMP/bb.$$

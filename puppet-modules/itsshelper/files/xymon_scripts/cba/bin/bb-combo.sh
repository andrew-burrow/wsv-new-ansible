#!/bin/sh

# bb-combo.sh
#
# BIG BROTHER COMBO SCRIPT
# Robert-Andre Croteau
#
# (c) Copyright Quest Software, Inc.  1997-2003  All rights reserved.
#
# Build a list of green status messages into work files
#  and send as a combo message
# any other color than green is sent immediately
#

if [ "$#" -lt 1 ]
then
	echo "bb-combo.sh called with no arguments"
	echo "Usage: bb-combo.sh add \"message\""
	echo "       bb-combo.sh end"
	exit 1
fi

# echo "***** BBHOME IS SET TO $BBHOME IN bb-combo.sh"
if test ! "$BBTMP"                      # GET DEFINITIONS IF NEEDED
then
        . $BBHOME/etc/bbdef.sh          # INCLUDE STANDARD DEFINITIONS
fi

case $1 in

add)	# if message is green add to work file
	# Otherwise send status immediately

	if [ "$DOCOMBO" != "TRUE" ]
	then
		$BB $BBDISP "$2"
	elif [ "$BBCOMBOID" = "" ]
	then
		echo "bb-combo.sh: BBCOMBOID variable is not set or has not been exported"
		echo "             combo add request ignored, sending status immediately"
		$BB $BBDISP "$2"
	else
		MSG="$2"
		set -f
		set bogus $2 >/dev/null 2>&1
		set +f
		shift
		host=$2
		color=$3
		if [ "$color" != "green" ]
		then
			#
			# Also send what you have already saved,
			# if there's a non-green, there's some chances
			#   others will follow so better send the good ones too
			# Only send if there's a workfile
			if [ -f $BBTMP/combo.${BBCOMBOID} ]
			then
				$BB $BBDISP "`$CAT $BBTMP/combo.${BBCOMBOID}`"
				$RM -f $BBTMP/combo.${BBCOMBOID}
				# remove the combo.msgs / combo.ttl / combo.$host files
				$RM -f $BBTMP/combo.*.${BBCOMBOID}
			fi
			#
			# Now send the non-green
			#
			$BB $BBDISP "$MSG"
		else
			#
			# If the previous check was non-green
			# Send immediately
			#
				SENDCOMBO="FALSE"
				#
				# Has the workfile exceed its time to live ?
				#
				if [ -f $BBTMP/combo.ttl.${BBCOMBOID} -a "$MAXCOMBOTTL" -ge 0 ]
				then
					NOWTIME=`$BBHOME/bin/touchtime -e 2>/dev/null`
					TTLTIME=`$CAT $BBTMP/combo.ttl.${BBCOMBOID}`
					DIFFTIME=`$EXPR $NOWTIME - $TTLTIME`
					if [ "$DIFFTIME" -ge "$MAXCOMBOTTL" ]
					then
						SENDCOMBO="TRUE"
					fi
				fi
				#
				# Has the # of messages in the workfile
				# exceeded the allowed maximum ?
				#
				if [ "$SENDCOMBO" != "TRUE" -a -f $BBTMP/combo.msgs.${BBCOMBOID} -a "$MAXCOMBOMSGS" -ge 1 ]
				then
					NUMMSGS=`$CAT $BBTMP/combo.msgs.${BBCOMBOID}`
					if [ "$NUMMSGS" -ge "$MAXCOMBOMSGS" ]
					then
						SENDCOMBO="TRUE"
					fi
				fi
				#
				# Would the updated workfile exceed the maximun
				# message size (MAXLINE)
				#
				if [ "$SENDCOMBO" != "TRUE" -a -f $BBTMP/combo.${BBCOMBOID} ]
				then
					# Don't redefine WCC in bbsys.local, it won't work
					# WCC is determined from WC
					set -f
					set `echo "$MSG" | $WCC -c 2>/dev/null` >/dev/null 2>&1
					set +f
					MSGSIZE=`echo $1`
					set `$WCC -c $BBTMP/combo.${BBCOMBOID} 2>/dev/null` >/dev/null 2>&1
					FILESIZE=`echo $1`
					TOTALSIZE=`$EXPR $MSGSIZE + $FILESIZE`
					if [ $TOTALSIZE -gt $MAXLINE ]
					then
						SENDCOMBO="TRUE"
					fi
				fi
				if [ "$SENDCOMBO" = "TRUE" ]
				then
					$BB $BBDISP "`$CAT $BBTMP/combo.${BBCOMBOID}`"
					$RM -f $BBTMP/combo.${BBCOMBOID}
					# remove the combo.msgs / combo.ttl / combo.$host files
					$RM -f $BBTMP/combo.*.${BBCOMBOID}
				fi
				if [ ! -f $BBTMP/combo.${BBCOMBOID} ]
				then
					echo "combo" > $BBTMP/combo.${BBCOMBOID}
					$BBHOME/bin/touchtime -e > $BBTMP/combo.ttl.${BBCOMBOID}
					echo "1" > $BBTMP/combo.msgs.${BBCOMBOID}
				fi
				echo "$MSG
" >> $BBTMP/combo.${BBCOMBOID}

		fi
	fi

	;;

end )	# send remaining contents of work file if any

	if [ "$DOCOMBO" = "TRUE" ]
	then
		if [ "$BBCOMBOID" = "" ]
		then
			echo "bb-combo.sh: BBCOMBOID variable is not set or has not been exported"
			echo "             combo end request ignored"
			exit 1
		else
			# Only send if there's a workfile
			if [ -f $BBTMP/combo.${BBCOMBOID} ]
			then
				$BB $BBDISP "`$CAT $BBTMP/combo.${BBCOMBOID}`"
				$RM -f $BBTMP/combo.${BBCOMBOID}
				# remove the combo.msgs / combo.ttl / combo.$host files
				$RM -f $BBTMP/combo.*.${BBCOMBOID}
			fi
		fi
	fi
	;;

start ) # Clean up before 1st message, just in case

	if [ "$DOCOMBO" = "TRUE" ]
	then
		if [ "$BBCOMBOID" = "" ]
		then
			echo "bb-combo.sh: BBCOMBOID variable is not set or has not been exported"
			echo "             combo end request ignored"
			exit 1
		else
			$RM -f $BBTMP/combo.${BBCOMBOID}
			# remove the combo.msgs / combo.ttl / combo.$host files
			$RM -f $BBTMP/combo.*.${BBCOMBOID}
		fi
	fi
	;;

esac

exit 0


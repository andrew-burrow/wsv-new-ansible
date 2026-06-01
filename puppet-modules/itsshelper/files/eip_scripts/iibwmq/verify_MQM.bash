#!/bin/bash

#
# program:	verifyMQ.bash
# author:	Boris Carli, WorkSafe, Nov 1 2012
# date:		November 1 2012
# purpose:	Validate an MQ Server installation post-install
#
printusage()
{
	echo "usage: $0"
	echo "	Environment veriable ENV is the installed environment name"
	echo "	It must be available in the environment prior to invocation"
}
MQMUSR=mqm		# MQ functional user
QMGR="MQVERIFY"		# will create a test qmgr to test with
if [ -z "$ENV" ] ; then
	printusage
	exit 1
fi
env=${ENV,,} # lower case
SPATH=/opt/$env/mqm/samp/bin	# path to sample lib routines
if [ ! -d $SPATH ] ; then
	printusage
	exit 1
fi

# common subroutine
#
doExec()
{
	cmd=$1
	echo "performing: $cmd"
	su $MQMUSR -c "$cmd"
}

cleanup()
{
	doExec "endmqm -p ${QMGR}"
	doExec "dltmqm ${QMGR}"
}
	
# Set up MQ environment so that commands can be executed
if [ -e /opt/$env/mqm/bin/setmqenv ] ; then
	. /opt/$env/mqm/bin/setmqenv -s
else
	echo "$env does not appear to be an installed MQ environment"
	printusage
	exit 1
fi

# Check the system configuration for mqm account with mqconfig
#
doExec "yes | mqconfig"

# create a test qmgr
#
doExec "crtmqm -z -u SYSTEM.DEAD.LETTER.QUEUE -lp 3 -ls 2 -lf 1024 -lc ${QMGR}"
res=$?
if [ $res -ne 0 ] ; then
	echo "System configuration is not suitable for MQ"
	exit 1
fi

res=$?
if [ $res -ne 0 ] ; then
	echo "Failed to create queue manager ${QMGR}"
	exit 1
fi

# start it up
#
doExec "strmqm -z ${QMGR}"
res=$?
if [ $res -ne 0 ] ; then
	echo "Failed to start queue manager ${QMGR}"
	cleanup
	exit 1
fi

# define and start listener on port 14141
#
doExec "echo \"define listener(LISTENER.TCP) trptype(TCP) control(qmgr) port(14141)\" | runmqsc ${QMGR} "
res=$?
if [ $res -ne 0 ] ; then
	echo "Failed to define listener on ${QMGR}"
	cleanup
	exit 1
fi

doExec "echo \"start listener(LISTENER.TCP)\" | runmqsc ${QMGR}"
res=$?
if [ $res -ne 0 ] ; then
	echo "Failed to start listener on ${QMGR}"
	cleanup
	exit 1
fi

# put a test message onto the SYSTEM.DEFAULT.LOCAL.QUEUE 
# then get the same test message back off this queue
#
doExec "echo \"starting mq test on \" `date`;dspmq;echo \"dis qmgr\" | runmqsc ${QMGR};PATH=$PATH:${SPATH};export PATH;echo \"e-bus test verify msg on $currDate\" `date` | amqsput SYSTEM.DEFAULT.LOCAL.QUEUE ${QMGR};echo \"test msg was put\";amqsget SYSTEM.DEFAULT.LOCAL.QUEUE ${QMGR}"
res=$?
if [ $res -ne 0 ] ; then
	echo "Failed to PUT/GET test message to system queue on ${QMGR}"
	cleanup
	exit 1
fi

# same test but this time to an explcitly created queue
#
QL="VERIFY.LOCAL.QUEUE"
doExec "echo \"DEFINE QLOCAL($QL)\" | runmqsc ${QMGR};"

doExec "echo \"dis qmgr\" | runmqsc ${QMGR};PATH=$PATH:${SPATH};export PATH;echo \"e-bus test verify msg on $currDate\" `date` | amqsput $QL ${QMGR};echo \"test msg was put\";amqsget $QL ${QMGR}"
res=$?
if [ $res -ne 0 ] ; then
	echo "Failed to PUT/GET test message to application queue on ${QMGR}"
	cleanup
	exit 1
fi


# listener status of qmgr
#
doExec "echo \"dis lsstatus(*)\" | runmqsc ${QMGR}"

# display current version
#
doExec "dspmqver"

cleanup


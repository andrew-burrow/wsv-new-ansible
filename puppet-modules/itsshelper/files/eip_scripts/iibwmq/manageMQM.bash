#/bin/bash
#
# Find any queue manager using the currently active installation
# Start or stop the queue manager (depending on parameter)

# The MQ environment must be set using /opt/<env>/mqm/bin/setmqenv 
# before this script is called

# Find the MQ installation name of the current environment
MQInst=$(dspmqinst -p $(dirname $(dirname $(which dspmqinst))) | awk "/^InstName:/ {print \$2}");
if [ -z "$MQInst" ] ; then
	echo "Failed: No MQ available in the environment"
	exit 1
fi

# Discover the MQ queue managers which are attached to this Installation
QMGRS=$(dspmq -o Installation | grep "\($MQInst\)" | awk -F "[()]" "{print \$2}")
for qmgr in $QMGRS ; do
	service mq_${qmgr} $1
done

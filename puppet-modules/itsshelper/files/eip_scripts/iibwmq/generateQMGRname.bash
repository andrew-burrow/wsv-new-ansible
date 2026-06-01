#!/bin/bash

# Show the queue manager name which will be generated
# for this server and the supplied <env> and <prop_file>

usage()
{
  echo "USAGE: $(basename $0) env props_file [server_name]"
}
  

if [ $(whoami) != "root" ];then
  echo "ERROR: script must be run as root"
  exit 1
fi

# Collect command line arguments
ENV=$1
export env=${ENV,,} # lower case
export UENV=${env^^} # upper case
export PROPS=$2
export ORIG_PROPS=$PROPS
export HOST=$3

if [ $# -lt 2 ] ; then
	usage
	exit 1
fi
CONFIGDIR=$(dirname $(dirname $(which $0)))/properties
if [ ! -f $CONFIGDIR/$PROPS.prop ] ; then
  echo "ERROR: props file not found: $PROPS"
  echo "Locate props file in properties directory, with .prop suffix"
  echo "Available props files are:"
  (cd $CONFIGDIR; ls *.prop | while read a ; do basename $a .prop ; done)
  exit 1
fi
PROPS=$CONFIGDIR/$PROPS.prop
. $PROPS

echo "Queue Manager for Env=${env}, Prop=${ORIG_PROPS}, Server=${HOST}"
echo "Queue Manager=$QMGRNAME"

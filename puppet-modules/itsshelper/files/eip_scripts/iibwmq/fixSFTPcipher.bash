#!/bin/bash
# 1 argument ( broker name )
# Discover all FtpServer configurable servers on the broker
# For each FtpServer, if the current cipher is aes-128-cbc, change
# it to aes128-ctr

# The script must be run in a shell where mqsiprofile has not been set.
# That is: before iib_init has been run.

if [ $# -ne 1 ] ; then
  echo "usage: $0 IIBNodeName"
  echo "e.g.   $0 IBDV1DJ0101"
  exit 1
fi

Node=$1
Env=${Node:2:3}
Env=${Env,,}

. /opt/$Env/iib/server/bin/mqsiprofile
Services=$(mqsireportproperties $Node -c FtpServer -o AllReportableEntityNames -n cipher | \
  awk -v qt="'" "/^  [^ ]/ {Service=\$1} ; \
       /cipher=/ {split(\$0,words,qt);if (words[2] ~ /aes128-cbc/) {print Service}}")

for SvcName in $Services ; do
  Cmd="mqsichangeproperties $Node -c FtpServer -o $SvcName -n cipher -v aes128-ctr"
  echo $Cmd
  eval $Cmd
done

SvcCount=$(echo $Services | wc -w)
echo "$SvcCount replacements attempted."
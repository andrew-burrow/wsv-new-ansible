#!/bin/bash
#
# use the renameMQInstallation.awk script to rename the installations
# to match the stack name
#
# Always operates on file /etc/opt/mqm/mqinst.ini

DIRNAME=$(dirname $(which $0))
DATE=$(date +%Y%m%d_%H%M%S)
cp /etc/opt/mqm/mqinst.ini /etc/opt/mqm/mqinst.ini.$DATE
cat /etc/opt/mqm/mqinst.ini | $DIRNAME/renameMQInstallation.awk > /etc/opt/mqm/mqinst.ini.new
cat /etc/opt/mqm/mqinst.ini.new > /etc/opt/mqm/mqinst.ini

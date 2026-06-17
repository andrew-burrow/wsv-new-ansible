#!/bin/bash
#
# /opt/scripts/common_vars.bash
#
# -   Define variables common to `itsshelper` scripts
#
# -   Derived from `itsshelper` scripts
#

# What host are the scripts running on?
HOST=$(hostname)

# What is the index of the host that the scripts are running on?
NUM=$(echo $HOST | grep -o '[0-9]*$')

# What is the name of the account to run the MQ daemon?
MQMUSR="mqm"

# What is the directory containing itsshelper MQ property files?
CONFIGDIR=/opt/properties

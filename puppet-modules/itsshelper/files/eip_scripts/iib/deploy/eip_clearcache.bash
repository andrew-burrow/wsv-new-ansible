#!/bin/bash


##################################################################
# Copyright 2005 - 2010 IT Shared Solutions
# 222 Exhibition Street, Melbourne, VIC 3000, Australia.
# All rights reserved. 
# This software is the confidential and proprietary information of 
# Victorian Workcover Authority.
#
# This script fetches and deploys on integration bus.
# 
# Date Created:	31/01/2017
# Author:	Hemesh Kumar
#
##################################################################
#
#                       C H A N G E   L O G                       
#
# Version  Date        Author     Comment
# ================================================================
# 1.0.0    31/01/2017  H Kumar    Initial version.
# 1.0.1    25/05/2017  H Kumar    Retrieving the cache map names
#                                 dynamically.
#
##################################################################



#########################################################
#
#       F U N C T I O N S
#
#########################################################

usage()
{
  echo "USAGE: $(basename $0) -i <integrationNode>"
  echo ""
  echo "  Mandatory Arguments:"
  echo "    -i <integrationNode>                  Specify the Integration Node"
  echo "    --integrationNode <integrationNode>               ,,              "
}

clearCacheMap()
{
  echo "Clearing Map: $1"
  
  mqsicacheadmin ${INTEGRATION_NODE} -c clearGrid -m $1
}

#########################################################
#
#       M A I N
#
#########################################################


###################################
# Get arguments
###################################
while [[ $# -gt 1 ]]
do
key="$1"
echo "${key}"
case $key in
  -i|--integrationNode)
  INTEGRATION_NODE="$2"
  shift
  ;;
  *)
  usage
  ;;
esac
shift
done

echo "Deploy Script parameters"
echo "------------------------"
echo "Integartion Node:     ${INTEGRATION_NODE}"

if [[ ( -z ${INTEGRATION_NODE} ) ]]; then
  usage
  exit 1
fi

MAP_NAMES=`mqsicacheadmin ${INTEGRATION_NODE} -c showMapSizes | grep Primary | grep -v SYSTEM | grep -Eo '^[^ ]+' | sort | uniq`

for MAP_NAME in ${MAP_NAMES}; do
  clearCacheMap ${MAP_NAME}
done

mqsicacheadmin ${INTEGRATION_NODE} -c showMapSizes

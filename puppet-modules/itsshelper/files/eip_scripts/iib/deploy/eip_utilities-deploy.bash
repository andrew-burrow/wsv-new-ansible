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
# Date Created:	18/07/2017
# Author:	Hemesh Kumar
#
##################################################################
#
#                       C H A N G E   L O G                       
#
# Version  Date        Author     Comment
# ================================================================
# 1.0.0    18/07/2017  H Kumar    Initial version.
#
##################################################################



#########################################################
#
#       F U N C T I O N S
#
#########################################################

usage()
{
  echo "USAGE: $(basename $0) -e <environment> -n <releaseName> -t <releaseType> -v <releaseVersion> -b <buildNumber> -u <artifactoryUser> -p <password>"
  echo ""
  echo "  Mandatory Arguments:"
  echo "    -e <environment>                      Specify the environment (ci1|dv1|sv1|ts1|ts2|ts3)"
  echo "    --env <environment>                               ,,                                   "
  echo "    -r <releaseName>                      Specify the release name (release branch)"
  echo "    --releaseName <releaseName>                       ,,                                "
  echo "    -t <releaseType>                      Specify the release type (release|integration)"
  echo "    --releaseType <releaseType>                       ,,                                "
  echo "    -v <releaseVersion>                    Specify the Release Version"
  echo "    --releaseVersion <releaseVersion>                 ,,              "
  echo "    -b <builNumber>                       Specify the Build Number"
  echo "    --builNumber <builNumber>                         ,,          "
  echo "    -u <artifactoryUser>                  Specify the artifactory user to retrieve artifacts"
  echo "    --user <artifactoryUser>                          ,,                                    "
  echo "    -p <password>                         Specify the artifactory user's password"
  echo "    --pwd <password>                                  ,,                         "
}

getDeployable()
{
  echo "Fetching: ${ARTIFACTORY_BASE_PATH}/${APP_NAME,,}/${RELEASE_NAME,,}/${RELEASE_VERSION}/$1"
  curl -u ${BAMBOO_USER}:${BAMBOO_USER_PWD} -o /var/iib/${ENVIRONMENT,,}/deployables/${CURRENT_DATE}/$1 -f -X GET ${ARTIFACTORY_BASE_PATH}/${APP_NAME,,}/${RELEASE_NAME,,}/${RELEASE_VERSION}/$1
}

deployJar()
{
  getDeployable $1
  
  if [[ -e /var/iib/${ENVIRONMENT,,}/deployables/${CURRENT_DATE}/$1 ]]; then
    echo "Deploying Jar:"
    echo "  Jar File:           /var/iib/${ENVIRONMENT,,}/deployables/${CURRENT_DATE}/$1"

    # Remove old JAR files
    rm ${ITSS_UTIL_BASE_DIR}/${APP_NAME}*
    cp /var/iib/${ENVIRONMENT,,}/deployables/${CURRENT_DATE}/$1 ${ITSS_UTIL_BASE_DIR}/$1
    chmod 775 ${ITSS_UTIL_BASE_DIR}/$1
    ln -s ${ITSS_UTIL_BASE_DIR}/$1 ${ITSS_UTIL_BASE_DIR}/${APP_NAME}.jar
    
    ls -al ${ITSS_UTIL_BASE_DIR}

  else
    echo "Cannot find deployable in artifactory: $1"
    exit 1
  fi
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
  -e|--env)
  ENVIRONMENT="$2"
  shift
  ;;
  -r|--releaseName)
  RELEASE_NAME="$2"
  shift
  ;;
  -t|--releaseType)
  RELEASE_TYPE="$2"
  shift
  ;;
  -v|--releaseVersion)
  RELEASE_VERSION="$2"
  shift
  ;;
  -b|--buildNumber)
  BUILD_NUMBER="$2"
  shift
  ;;
  -u|--user)
  BAMBOO_USER="$2"
  shift
  ;;
  -p|--pwd)
  BAMBOO_USER_PWD="$2"
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
echo "Environment:          ${ENVIRONMENT}"
echo "Release Name:         ${RELEASE_NAME}"
echo "Release Type:         ${RELEASE_TYPE}"
echo "Release Version:      ${RELEASE_VERSION}"
echo "Build Number:         ${BUILD_NUMBER}"
echo "Bamboo User:          ${BAMBOO_USER}"

if [[ ( -z ${ENVIRONMENT} ) || ( -z ${RELEASE_NAME} ) || ( -z ${RELEASE_TYPE} ) || ( -z ${RELEASE_VERSION} ) || ( -z ${BUILD_NUMBER} ) || ( -z ${BAMBOO_USER} ) || ( -z ${BAMBOO_USER_PWD} ) ]]; then
  usage
  exit 1
fi

if [[ ${RELEASE_TYPE,,} = "release" ]]; then
  ARTIFACTORY_BASE_PATH="http://artifactory.itss.vic.gov.au/artifactory/eip-release-local/itss/eip-iib-release"
else
  ARTIFACTORY_BASE_PATH="http://artifactory.itss.vic.gov.au/artifactory/eip-snapshot-local/itss/eip-iib-integration"
fi

APP_NAME=ReportGenerator

ITSS_UTIL_BASE_DIR=/opt/${ENVIRONMENT,,}/utils/report_generator

CURRENT_DATE=`date +%d-%^b-%Y`

mkdir -p /var/iib/${ENVIRONMENT,,}/deployables/${CURRENT_DATE}

deployJar ${APP_NAME}_${RELEASE_VERSION}-${BUILD_NUMBER}.jar

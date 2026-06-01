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
# Date Created:	05/07/2016
# Author:	Hemesh Kumar
#
##################################################################
#
#                       C H A N G E   L O G                       
#
# Version  Date        Author     Comment
# ================================================================
# 1.0.0    05/07/2016  H Kumar    Initial version.
# 1.0.1    25/05/2017  H Kumar    Changed the artifactory path to
#                                 retrieve the deployables.
# 1.1.0    05/06/2017  H Kumar    Fetch deployables for a release
# 1.2.0    02/10/2017  Murtuza    Fetch and deploy templates for a release
# 1.2.1    09/11/2017  H Kumar    Change to automatically detect any
#                                 deployed libraries and delete them.
# 1.2.2    26/06/2021  S Tomney   Update artifactory endpoint to aws
# 1.2.3    28/06/2021  S Tomney   moved -k option
#
##################################################################



#########################################################
#
#       F U N C T I O N S
#
#########################################################

usage()
{
  echo "USAGE: $(basename $0) -e <environment> -r <releaseName> -t <releaseType> -a <appName> -v <releaseVersion> -b <buildNumber> -i <integrationNode> -u <artifactoryUser> -p <password>"
  echo ""
  echo "  Mandatory Arguments:"
  echo "    -e <environment>                      Specify the environment (ci1|dv1|sv1|ts1|ts2|ts3)"
  echo "    --env <environment>                               ,,                                   "
  echo "    -r <releaseName>                      Specify the release name (release branch)"
  echo "    --releaseName <releaseName>                       ,,                                "
  echo "    -t <releaseType>                      Specify the release type (release|integration)"
  echo "    --releaseType <releaseType>                       ,,                                "
  echo "    -a <appName>                          Specify the Application / Module Name"
  echo "    --appName <appName>                               ,,              "
  echo "    -v <releaseVersion>                    Specify the Release Version"
  echo "    --releaseVersion <releaseVersion>                 ,,              "
  echo "    -b <builNumber>                       Specify the Build Number"
  echo "    --builNumber <builNumber>                         ,,          "
  echo "    -i <integrationNode>                  Specify the Integration Node"
  echo "    --integrationNode <integrationNode>               ,,              "
  echo "    -u <artifactoryUser>                  Specify the artifactory user to retrieve artifacts"
  echo "    --user <artifactoryUser>                          ,,                                    "
  echo "    -p <password>                         Specify the artifactory user's password"
  echo "    --pwd <password>                                  ,,                         "
}

getDeployable()
{
  echo "Fetching: ${ARTIFACTORY_BASE_PATH}/${APP_NAME,,}/${RELEASE_NAME,,}/${RELEASE_VERSION}/$1"
  curl -u ${BAMBOO_USER}:${BAMBOO_USER_PWD} -k -o /var/iib/${ENVIRONMENT,,}/deployables/${CURRENT_DATE}/$1 -f -X GET ${ARTIFACTORY_BASE_PATH}/${APP_NAME,,}/${RELEASE_NAME,,}/${RELEASE_VERSION}/$1
}

getTemplates()
{
  echo "Fetching: ${ARTIFACTORY_BASE_PATH}/${APP_NAME,,}/${RELEASE_NAME,,}/${RELEASE_VERSION}/templates/$1_templates.tar"
  curl -u ${BAMBOO_USER}:${BAMBOO_USER_PWD} -k -o /var/iib/${ENVIRONMENT,,}/deployables/${CURRENT_DATE}/$1_templates.tar -f -X GET ${ARTIFACTORY_BASE_PATH}/${APP_NAME,,}/${RELEASE_NAME,,}/${RELEASE_VERSION}/templates/$1_templates.tar
}

deployBar()
{
  INTEGRATION_SERVER=$1
  getDeployable $2
  
  if [[ -e /var/iib/${ENVIRONMENT,,}/deployables/${CURRENT_DATE}/$2 ]]; then
    echo "Deploying Bar:"
    echo "  Integration Node:   ${INTEGRATION_NODE}"
    echo "  Integration Server: ${INTEGRATION_SERVER}"
    echo "  Bar File:           /var/iib/${ENVIRONMENT,,}/deployables/${CURRENT_DATE}/$2"
    
    # List the details of currently deployed apps
    mqsilist ${INTEGRATION_NODE} -e ${INTEGRATION_SERVER} -d 2 > /var/iib/${ENVIRONMENT,,}/deployables/${CURRENT_DATE}/${INTEGRATION_NODE}_${INTEGRATION_SERVER}_${CURRENT_DATE_TIME}.out

    mqsideploy ${INTEGRATION_NODE} -e ${INTEGRATION_SERVER} -a /var/iib/${ENVIRONMENT,,}/deployables/${CURRENT_DATE}/$2 -w 2400
    if [ $? -ne 0 ]; then
      echo "ERROR occured while deploying bar: $2"
      echo "Exiting deploy script..."
      exit 1
    fi
    
    # Delete any Library if deployed.
    LIB_NAMES=`mqsilist ${INTEGRATION_NODE} -e ${INTEGRATION_SERVER} | grep Library | cut -d "'" -f 2`
    
    for LIB_NAME in ${LIB_NAMES}; do
      LIBS_TO_DELETE="${LIBS_TO_DELETE:-}:${LIB_NAME}"
    done

    if [[ ! -z ${LIBS_TO_DELETE} ]]; then
      LIBS_TO_DELETE=${LIBS_TO_DELETE#:}

      echo "Deleting Libraries: ${LIBS_TO_DELETE}"
      mqsideploy ${INTEGRATION_NODE} -e ${INTEGRATION_SERVER} -d ${LIBS_TO_DELETE} -w 1200
    fi
    
    echo "Deployed Apps"
    echo "-------------"
    mqsilist ${INTEGRATION_NODE} -e ${INTEGRATION_SERVER}
  fi
}

deployTemplates()
{
  getTemplates $1

  if [[ -e  /var/iib/${ENVIRONMENT,,}/deployables/${CURRENT_DATE}/$1_templates.tar ]]; then
    echo "Templates found. Extracting..."
    tar -xvf /var/iib/${ENVIRONMENT,,}/deployables/${CURRENT_DATE}/$1_templates.tar -C /var/iib/${ENVIRONMENT}/common/xsl
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
  -a|--appName)
  APP_NAME="$2"
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
  -i|--integrationNode)
  INTEGRATION_NODE="$2"
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
echo "Integartion Node:     ${INTEGRATION_NODE}"
echo "Release Name:         ${RELEASE_NAME}"
echo "Release Type:         ${RELEASE_TYPE}"
echo "Application Name:     ${APP_NAME}"
echo "Release Version:      ${RELEASE_VERSION}"
echo "Build Number:         ${BUILD_NUMBER}"
echo "Bamboo User:          ${BAMBOO_USER}"

if [[ ( -z ${ENVIRONMENT} ) || ( -z ${RELEASE_NAME} ) || ( -z ${RELEASE_TYPE} ) || ( -z ${APP_NAME} ) || ( -z ${RELEASE_VERSION} ) || ( -z ${BUILD_NUMBER} ) || ( -z ${INTEGRATION_NODE} ) || ( -z ${BAMBOO_USER} ) || ( -z ${BAMBOO_USER_PWD} ) ]]; then
  usage
  exit 1
fi

if [[ ${RELEASE_TYPE,,} = "release" ]]; then
  ARTIFACTORY_BASE_PATH="https://artifactory-aws.itss.vic.gov.au/artifactory/eip-release-local/itss/eip-iib-release"
else
  ARTIFACTORY_BASE_PATH="https://artifactory-aws.itss.vic.gov.au/artifactory/eip-snapshot-local/itss/eip-iib-integration"
fi

CURRENT_DATE=`date +%d-%^b-%Y`
CURRENT_DATE_TIME=`date +%d%m%YT%H%M%S`

mkdir -p /var/iib/${ENVIRONMENT,,}/deployables/${CURRENT_DATE}

EG_NAMES="VWA TAC Common"

for EG_NAME in ${EG_NAMES}; do
  deployBar IS-${ENVIRONMENT,,}-${EG_NAME,,} ${APP_NAME}_${RELEASE_VERSION}-${BUILD_NUMBER}-${EG_NAME^^}.bar
done

deployTemplates ${APP_NAME,,}_${RELEASE_VERSION}_${BUILD_NUMBER}
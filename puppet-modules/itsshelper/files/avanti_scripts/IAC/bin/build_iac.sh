#!/bin/sh
# This script ideally will be called by a build server autmatically upon detetction of changes in SVN

[ -d /tmp/IAC_BUILD ] && rm -Rf /tmp/IAC_BUILD
mkdir /tmp/IAC_BUILD
pushd /tmp/IAC_BUILD
svn co http://dev1bld1.dev.tac/svn/ITSS_Environment_Services/utils/IAC
. IAC/bin/version.properties
BUILD_NUM=`/opt/IAC/bin/next_build.sh -a ITSS -c IAC -v $VERSION`
NEW_VERSION=$VERSION.$BUILD_NUM
BUILD_DATE=`date`
sed -ie "s/{{VERSION}}/$NEW_VERSION/g" IAC/lib/*.py
sed -ie "s/{{BUILD_DATE}}/$BUILD_DATE/g" IAC/lib/*.py
pushd /tmp/IAC_BUILD/IAC
SVN_URL=`svn info | grep URL | awk '{print $2}'`
REVISION=`svn info | grep Revision | awk '{print $2}'`
popd
/opt/IAC/bin/put.sh -a ITSS -c IAC -v $NEW_VERSION -d IAC -p SVN_URL=$SVN_URL -p REVISION=$REVISION

# Tag SVN with build number
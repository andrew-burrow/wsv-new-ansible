#!/bin/sh
# If IAC is not on the node then initially get it from SVN
# Otherwise always get the most recent version from Artifactory

pushd /opt
[ ! -d /opt/IAC ] && svn co http://dev1bld1.dev.tac/svn/ITSS_Environment_Services/utils/IAC && chmod +x /opt/IAC/bin/*sh && exit
[ -d /opt/IAC/bin ] && chmod +x /opt/IAC/bin/*sh
[ -d /tmp/IAC_TMP ] && rm -Rf /tmp/IAC_TMP
/opt/IAC/bin/get.sh -r build -a ITSS -c IAC -v `/opt/IAC/bin/get_latest.sh -a ITSS -c IAC` -t /tmp/IAC_TMP
[ -d /opt/IAC ] && rm -Rf /opt/IAC
mkdir /opt/IAC/
cp -R /tmp/IAC_TMP/* /opt/IAC/
chmod +x /opt/IAC/bin/*sh



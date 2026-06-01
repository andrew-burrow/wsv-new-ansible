
# subroutine exitOnRc - tests to see if rc is non zero and exits with that rc
#                      and appopriate message
#
. $INSTALLDIR_BLD/db2rtcl/log.bash
. $INSTALLDIR_BLD/db2rtcl/try.bash

exitOnRc()
{
       rc=$1
       msg=$2
       if [[ $rc -ne 0 ]] ; then
               log $msg
               exit $rc
       fi
}


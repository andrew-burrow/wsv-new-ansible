
# subroutine "checkFS":         checks filesytem
#
. $INSTALLDIR_BLD/db2rtcl/log.bash
. $INSTALLDIR_BLD/db2rtcl/try.bash

checkFS()
{
        FSNAME=$1
        FSSIZE=$2
        try "df -h $FSNAME"
        if [ ! -z $FSSIZE ] ; then      # size check
                FSMEGS=`df -Pm $FSNAME | tail -1 | awk '{print $4}'`
                if [ $FSMEGS -lt $FSSIZE ] ; then
                        msg="error: filesystem space - $FSNAME is only ${FSMEGS}M but should be at least ${FSSIZE}M"
                        log $msg
                        exit 1
                fi
        fi
}

# subroutine "log":	logs an operation
#
log()
{
    line="$@"
    now=`date +"%Y-%m-%d %H:%M:%S"`
    message="$now	$line"
    echo $message | tee -a $LOGFILE
}


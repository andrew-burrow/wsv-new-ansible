#!/bin/bash
#
# Script to download the QAS AUS datasets and create a tar file for
# distribution to QAS server for update.
#

# Set up some variables
SCRIPT=`basename $0`
DATE=`date "+%Y%m%d%H:%M"`
SHARE_NAME0="//winvmut14/d$"
AUTH_FILE="/usr/local/.auth/winvmut14.auth"
TGT_DIR="/software/packages/qas/Dataplus/Data"
AUS_DIR="QAS ElectronicUpdates/Data/AUS"

TMP_DIR=/var/tmp
NEW_DIR=${TMP_DIR}/AUS_dirs.qas
OLD_DIR=${TMP_DIR}/AUS_dirs_old.qas

LOG_DIR="/var/log"
LOG=${LOG_DIR}/${SCRIPT}.log.${DATE}

SMBCLIENT="/usr/bin/smbclient"
GZIP="/bin/gzip"
SCP="/usr/bin/scp"

MAXRC=0

function log () {
   LOG_ENT="${DATE} $*"
   echo ${LOG_ENT} >> ${LOG}

   return
}

[[ -r ${LOG} ]] && touch ${LOG}

log "INFO    ###### ${0} Starting new QAS update run ######"
log "INFO    Getting list of directories from ${SHARE_NAME0}/${AUS_DIR}"
COMMAND="cd \"${AUS_DIR}\"; dir"
${SMBCLIENT} ${SHARE_NAME0} -A ${AUTH_FILE} -c "${COMMAND}" > /tmp/dir_list.qas 2>> ${LOG}

# Extract just the directory names from the list (not the . and .. dirs)
cat /tmp/dir_list.qas |awk '/^  [0-9]/{print $1}' > ${NEW_DIR}

# If the old directories file does not exist create an empty one
if [ ! -r ${OLD_DIR} ]
then
   log "INFO    ${OLD_DIR} does not exist - creating"
   touch ${OLD_DIR}
fi

# If there are new directories then process them
if [[ `cat ${NEW_DIR} |grep -vf ${OLD_DIR}` != "" ]]
then
   log "INFO    New directories found in ${AUS_DIR}"
   cat ${NEW_DIR} |grep -vf ${OLD_DIR} |while read DIR
   do
      log "INFO    Downloading files to ${TGT_DIR} as AUS_${DIR}.tar"
      SRC_DIR="${AUS_DIR}/${DIR}"
      ${SMBCLIENT} ${SHARE_NAME0} -A ${AUTH_FILE} -D "${SRC_DIR}" -Tc ${TGT_DIR}/AUS_${DIR}.tar 2>> ${LOG}
      RC=$?

      [[ ${RC} -gt ${MAXRC} ]] && export MAXRC=${RC}

      # Compress the file using gzip to save some space
      if [ -r ${TGT_DIR}/AUS_${DIR}.tar ]
      then
	 ${GZIP} -9 ${TGT_DIR}/AUS_${DIR}.tar 2>> ${LOG}
	 RC=$?
	 [[ ${RC} -ne 0 ]] && log "ERROR   gzip operation returned error - RC = ${RC}"

	 [[ ${RC} -gt ${MAXRC} ]] && export MAXRC=${RC}
      fi
   done
else
   log "INFO    No new directories found in ${AUS_DIR}"
fi

mv ${NEW_DIR} ${OLD_DIR}

log "INFO    ###### ${0} complete - Max RC = ${MAXRC} ######"

exit

#!/bin/bash
#
# Script to download the QAS AUG datasets and create a tar file for
# distribution to QAS server for update.
#

# Set up some variables
SCRIPT=`basename $0`
DATE=`date "+%Y%m%d%H:%M"`
SHARE_NAME0="//winvmut14/d$"
AUTH_FILE="/usr/local/.auth/winvmut14.auth"
TGT_DIR="/var/www/html/qas"
AUG_DIR="QAS ElectronicUpdates/Data/AUG"

TMP_DIR=/var/tmp
NEW_DIR=${TMP_DIR}/AUG_dirs.qas
OLD_DIR=${TMP_DIR}/AUG_dirs_old.qas

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
log "INFO    Getting list of directories from ${SHARE_NAME0}/${AUG_DIR}"

if [ ! -d ${TGT_DIR} ];then
   mkdir -p ${TGT_DIR}
   log "INFO    Target dir ${TGT_DIR} did not exist - creating"
fi

COMMAND="cd \"${AUG_DIR}\"; dir"
${SMBCLIENT} ${SHARE_NAME0} -A ${AUTH_FILE} -c "${COMMAND}" > ${TMP_DIR}/dir_list.qas 2>> ${LOG}

# Extract just the directory names from the list (not the . and .. dirs)
cat ${TMP_DIR}/dir_list.qas |awk '/^  [0-9]/{print $1}' > ${NEW_DIR}

# If the old directories file does not exist create an empty one
if [ ! -r ${OLD_DIR} ]
then
   log "INFO    ${OLD_DIR} does not exist - creating"
   touch ${OLD_DIR}
fi

# If there are new directories then process them
if [[ `cat ${NEW_DIR} |grep -vf ${OLD_DIR}` != "" ]]
then
   log "INFO    New directories found in ${AUG_DIR}"
   cat ${NEW_DIR} |grep -vf ${OLD_DIR} |while read DIR
   do
      log "INFO    Downloading files to ${TGT_DIR} as AUG_${DIR}.tar"
      SRC_DIR="${AUG_DIR}/${DIR}"
      ${SMBCLIENT} ${SHARE_NAME0} -A ${AUTH_FILE} -D "${SRC_DIR}" -Tc ${TGT_DIR}/AUG_${DIR}.tar 2>> ${LOG}
      RC=$?

      [[ ${RC} -gt ${MAXRC} ]] && export MAXRC=${RC}

      # Compress the file using gzip to save some space
      if [ -r ${TGT_DIR}/AUG_${DIR}.tar ]
      then
	 ${GZIP} -9 ${TGT_DIR}/AUG_${DIR}.tar 2>> ${LOG}
	 RC=$?
	 [[ ${RC} -ne 0 ]] && log "ERROR   gzip operation returned error - RC = ${RC}"

	 [[ ${RC} -gt ${MAXRC} ]] && export MAXRC=${RC}
      fi
   done
else
   log "INFO    No new directories found in ${AUG_DIR}"
fi

mv ${NEW_DIR} ${OLD_DIR}

log "INFO    ###### ${0} complete - Max RC = ${MAXRC} ######"

exit

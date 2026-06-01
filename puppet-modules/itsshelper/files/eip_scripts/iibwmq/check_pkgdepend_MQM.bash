#!/bin/bash

#
# program:      check_pkgdepend_MQ.bash
# author:       Boris Carli, WorkSafe
# date:         November 1 2012
# purpose:      Check on System V IPC Settingsas on RHEL6 for MQv7 as per InfoCentre ref:
#               http://publib.boulder.ibm.com/infocenter/wmqv7/v7r0/index.jsp?topic=%2Fcom.ibm.mq.amq1ac.doc%2Flq10120_.htm
#               Program checks to see that specific dependant libs are included.
#

PROG=`basename $0 .bash`        # get short name of script
PRODUCT=${PROG##*_} 		#PRODUCT derived from script name
echo $PRODUCT
pkgs=( 
	libstdc++-4.7.0-5.fc17.x86_64
	gcc-4.4.6-4.el6.x86_64
)

rc=0				# exit script with this return code
notFound=0			# keep track of total dependencies not found
for i in "${pkgs[@]}"
do
   :
   found=false
   printf "checking %s\n" $i

   for j in `rpm -aq` 
   do
      :
      if `echo ${j} | grep "${i}" 1>/dev/null 2>&1` ; then
	 # printf "\t%s exists as %s\n" $i $j
	 found=true
	 name=$j
	 break
      fi
   done
   if ${found}
   then
      printf "\t=> %s exists as %s\n" $i $name
   else
      printf "\t=> %s not found - searching for approximation containing name " $i
      if [[ $i =~ ^([A-Za-z0-9+-]+)-[0-9].* ]] ; then
	 found=false
         alt=${BASH_REMATCH[1]}
         printf "\"%s\" ....\n" $alt
	 for j in `rpm -aq`
	 do
      	    :
            if [[ $j =~ $alt ]] ; then
               printf "\t\t\"%s\" looks like a close approximation\n" $j
               found=true
               name=$j
	       rc=${rc-1}
               break
            fi
	 done
	 if ! ($found) ; then
               printf "\t\terror: failed to resolve on approximation\n"
	       notFound=$(($notFound + 1))
	       rc=1
	 fi
      else
	 printf "???? - internal error: failed to resolve common name of %s - please ammend regexp.\n" $i
	 notFound=$(($notFound + 1))
	 rc=1
      fi
   fi
done

echo "Total items not found $notFound; exiting with rc=$rc"
exit $rc

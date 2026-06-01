# subroutine assessBuildState:	Assesses whether desired operation for product
#				makes statefull sense.
# RULES:
#	1. Can only perform an install if no previous install was done
#		i.e. there is no install_<PRODUCT>_<VERSION> build target.
#	2. Can only perform an update if a previous update or install was done
#		i.e. there must exist an update_<PRODUCT>_<VERSION> or failing
#		that an install_<PRODUCT>_<VERSION> build target.
#		In either case, UPDATEVERSION has to be higher than the 
#		current PRODUCT VERSION visible in existing build target name.
#	3. Can only perform an uninstall if there exists a build target, i.e
#		install_<PRODUCT>_<VERSION> or update_<PRODUCT>_<VERSION> 
#
# SORTing:
#	Updates will be found firstx followed last by installs:
#	update_<PRODUCT>_<VERSION>
#	install_<PRODUCT>_<VERSION>
#
. $INSTALLDIR_BLD/db2rtcl/log.bash
. $INSTALLDIR_BLD/db2rtcl/try.bash

assessBuildState()
{
    OPERATION=$1
    PRODUCT=$2
    
    S='assessBuildState'
    
    set -o pipefail
    cd ${SHCDIR}
    CURRENTVERSION=`ls *_${PRODUCT}_* | sort -r | head -1`
    CURRENTVERSIONIM=`ls *_IM_* | sort -r | head -1`
    CURRENTVERSIONIHS=`ls *_IHS_* | sort -r | head -1`
    CURRENTVERSIONLMT=`ls *_LMT_* | sort -r | head -1`
    CURRENTVERSIONMQM=`ls *_MQM_* | sort -r | head -1`
    CURRENTVERSIONPLG=`ls *_PLG_* | sort -r | head -1`
    CURRENTVERSIONWAS=`ls *_WAS_* | sort -r | head -1`
	CURRENTVERSIONSDK=`ls *_SDK_* | sort -r | head -1`
    log "$S - assessing if $OPERATION on $PRODUCT is allowed given current state $CURRENTVERSION"
    
    case $OPERATION in
        'install')	# RULE 1
	    if [ "X" = "X"${CURRENTVERSION} ] ; then              # no current version found
		if [ $PRODUCT != "IM" -a "X" = "X"${CURRENTVERSIONIM} ] ; then	# not installing IM and also no IM present
		  if [ $PRODUCT = "IHS" -o $PRODUCT = "PLG" -o $PRODUCT = "WAS" -o $PRODUCT = "SDK" ] ; then
		    log "$S - determined no dependant installation manager ${SHCDIR}${PS}${OPERATION}_IM* therefore NOT ok to $OPERATION"
		    exit 1
		  else
		    log "$S - no IM and no current ${SHCDIR}${PS}${OPERATION}_${PRODUCT}* therefore ok to $OPERATION"
		  fi
		else
		    log "$S - prod=IM or currentVersionIM not blank [ ${CURRENTVERSIONIM} ] and no current ${SHCDIR}${PS}${OPERATION}_${PRODUCT}* therefore ok to $OPERATION"
		fi
	    else
		log "$S - determined there is already a $CURRENTVERSION therefore NOT ok to $OPERATION"
		exit 1	
	    fi
            ;;
        'update')	# RULE 2
	    if [ -z $CURRENTVERSION ] ; then
		msg="$S - determined no current ${SHCDIR}${PS}*_${PRODUCT}* therefore NOT ok to $OPERATION"
		log $msg
		exit 1
	    else	# CURRENTVERSION exists - determine if $UPDATEVERSION exceeds this
		if [ ! -z $UPDATEVERSION ] ; then
				#if [[ $VERSINFO =~ v[:]*([0-9\.]+) ]] ; then
		    if [[ $CURRENTVERSION =~ ([0-9\.]+) ]] ; then
			VERSINFO=`echo ${BASH_REMATCH[1]} | sed -e 's/\.//g'`
			log "$S - test if \"$UPDATEVERSION -gt $VERSINFO\""
			if [ $UPDATEVERSION -gt $VERSINFO ] ; then
			    msg="$S - ok to apply $UPDATEVERSION over current $VERSINFO ...."
			    log $msg
			else
			    msg="$S - invalid to apply $UPDATEVERSION over current $VERSINFO - aborting ...."
			    log $msg
			    exit 1
			fi
		    else
			msg="$S - failed to determine VERSINFO from $CURRENTVERSION - aborting ...."
			log $msg
			exit 1
		    fi
		else	# no UPDATEVERSION
		    msg="$S - has determined there is no $UPDATEVERSION to update to - aborting ...."
		    log $msg
		    exit 1
		fi
	    fi
            ;;
        'uninstall')	# RULE 3
	    if [ -z $CURRENTVERSION ] ; then
		msg="$S - determined there is/are NO current $SHCDIR${PS}*_${PRODUCT}* targets therefore can not $OPERATION"
		log $msg
		exit 1	
	    else
		if [ $PRODUCT = "IM" ] ; then
		    if [ "X"${CURRENTVERSIONIHS} != "X" -o "X"${CURRENTVERSIONWAS} != "X" -o "X"${CURRENTVERSIONPLG} != "X" -o "X"${CURRENTVERSIONSDK} != "X" ] ; then
			log "$S - determined there are still dependant installation manager components therefore NOT ok to $OPERATION"
			exit 1
		    fi
		else
		    log "$S - determined current build state $CURRENTVERSION therefore ok to $OPERATION"
		fi
	    fi
            ;;
        *)
            msg="$S - OPERATION $OPERATION unsupported in subroutine assessBuildTarget - aborting ...."
	    log $msg
	    exit 1	
            ;;
    esac
}

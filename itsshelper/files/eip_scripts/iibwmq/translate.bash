#!/bin/bash
#
# /opt/scripts/translate.bash
#
# -   Translate a template using a mapping and a properties file
#     with args:
#
#     1) template - contains tokens to be substituted
#     2) properties file - contains variables
#     3) mapping - name=value pairs where name is the token and value is the
#        variable name whose value is substituted for the token
#     4) output - translated output file
#
# -   Derived from script in `itsshelper` repository
#

usage()
{
    echo "USAGE: $(basename $0) TEMPLATE-FILE PROPS-FILE MAPPING-FILE OUT-FILE"
}

# ----------------------------------------------------------------------------
# Check command line argument count
#
if [ $# -ne 4 ] ; then
  usage
  exit 1
fi

# ----------------------------------------------------------------------------
# Collect command line arguments
#
TEMPLATE=$1
PROPSFILE=$2
MAPPING=$3
OUTFILE=$4

# ----------------------------------------------------------------------------
# Check existence of files required for templating
#
if [ ! -f $TEMPLATE ] || [ ! -f $PROPSFILE ] || [ ! -f $MAPPING ]
then
    echo "ERROR: check arguments are valid full paths"
    usage
    exit 1
fi

# ----------------------------------------------------------------------------
# Check write access to output file
#
cp -f $TEMPLATE $OUTFILE
if [ $? -ne 0 ]; then
  echo "Unable to write output file."
  exit 1
fi

# ----------------------------------------------------------------------------
# Source the common build info
#
ROOTDIR=$(dirname $0)
source ${ROOTDIR}/common_vars.bash

# ----------------------------------------------------------------------------
# Rewrite template to output file
#
source ${PROPSFILE}
( cat ${MAPPING};echo ) | \
    while read line
    do
        #ignore comments
        if [[ $line =~ "^#" ]]
        then
            echo "Skipping comment line..."
        else
            #extrapolate token in the template
            TOKEN=$(echo $line | cut -d= -f1)
            VAR=$(echo $line | cut -d= -f2)
            if [ -z "${TOKEN}" -o -z "${VAR}" ]
            then
                echo "Skipping empty line... $line"
            else
                VAL=${!VAR}
                if [ -z "${VAL}" ]
                then
                    echo "ERROR: ${VAR} is not defined in ${PROPSFILE}"
                    exit 1
                fi
                sed -i -e "s/${TOKEN}/${VAL}/g" $OUTFILE
            fi
        fi
    done
if [ $? -ne 0 ]
then
    echo "Creation of command file failed"
    exit 1
fi

#!/bin/bash
#translate.bash - translate a template using a mapping and a properties file
# args:
#  1) template - contains tokens to be substituted
#  2) properties file - contains variables
#  3) mapping - name=value pairs where name is the token and value is the variable name whose value is substituted for the token
#  4) output - translated output file

usage()
{
  echo "USAGE: $(basename $0) template-file props-file mapping-file out-file"
}

if [ $# -ne 4 ] ; then
  usage
  exit 1
fi

TEMPLATE=$1
PROPS=$2
MAPPING=$3
OUTFILE=$4
if [ ! -f $TEMPLATE ] || [ ! -f $PROPS ] || [ ! -f $MAPPING ] ; then
  echo "ERROR: check arguments are valid full paths"
  usage
  exit 1
fi

. ${PROPS}

cp -f $TEMPLATE $OUTFILE
if [ $? -ne 0 ]; then
  echo "Unable to write output file."
  exit 1
fi

( cat ${MAPPING};echo ) | \
while read line; do
  #ignore comments
  if [[ $line =~ "^#" ]] ; then
    echo "Skipping comment line..."
  else
    #extrapolate token in the template
    TOKEN=$(echo $line | cut -d= -f1)
    VAR=$(echo $line | cut -d= -f2)
    if [ -z "${TOKEN}" -o -z "${VAR}" ] ; then
      echo "Skipping empty line... $line"
    else
      VAL=${!VAR}
#       echo TOKEN=$TOKEN, VAR=$VAR, VAL=$VAL
      if [ -z "${VAL}" ] ; then
        echo "ERROR: ${VAR} is not defined in ${PROPS}"
          exit 1
        fi
      sed -i -e "s/${TOKEN}/${VAL}/g" $OUTFILE
    fi
  fi
done
if [ $? -ne 0 ] ; then
  echo "Creation of command file failed"
  exit 1
fi

#!/bin/bash
#
# /opt/scripts/translate.bash
#
# -   Generate an MQSC file from a properties file by expansion of the
#     template named in the properties file
#
# -   Derived from script in `itsshelper` repository
#

usage()
{
    echo "usage: $(basename $0) ENV PROPS OUTFILE"
    echo ""
    echo "Generate an MQSC file from PROPS by expansion of the template named in"
    echo "PROPS, and write the output to OUTFILE.  Accept the following arguments:"
    echo ""
    echo "ENV        Environment identifier, e.g. 'dv1'"
    echo "PROPS      Basename of properties file located in '/opt/properties'"
    echo "OUTFILE    Filename to which translated output is written"
    echo ""
    echo "Note that the basename of the template file is read from PROPS, and the"
    echo "matching template mapping file is used."
}

# ----------------------------------------------------------------------------
# Check command line argument count
#
if [ $# -ne 3 ] ; then
    echo "error:  Three arguments expected" >&2
    echo
    usage
    exit 1
fi

# ----------------------------------------------------------------------------
# Collect command line arguments
#
ENV=$1
PROPS=$2
OUTFILE=$3

# ----------------------------------------------------------------------------
# Source the properties file to get TEMPLATE
#
PROPSFILE="/opt/properties/${PROPS}.prop"
if [ ! -f "${PROPSFILE}" ]
then
    echo "error: Props file does not exist: ${PROPSFILE}" >&2
    echo
    usage
    exit 1
fi
source ${PROPSFILE}

# ----------------------------------------------------------------------------
# Check existence of files required for templating
#
if [ -z "${TEMPLATE}" ]
then
    echo "error: Props file does not define 'TEMPLATE': ${PROPSFILE}" >&2
    echo
    usage
    exit 1
else
    MAPPING="${TEMPLATE}.map"
fi
if [ ! -f "${TEMPLATE}" ]
then
    echo "error: Template file does not exist: ${TEMPLATE}" >&2
    echo
    usage
    exit 1
fi
if [ ! -f "${MAPPING}" ]
then
    echo "error: Template map file does not exist: ${MAPPING}" >&2
    echo
    usage
    exit 1
fi

# ----------------------------------------------------------------------------
# Check write access to output file
#
cp -f "${TEMPLATE}" "${OUTFILE}"
if [ $? -ne 0 ]
then
    echo "error: Unable to write output file: ${OUTFILE}" >&2
    echo
    usage
    exit 1
fi

# ----------------------------------------------------------------------------
# Rewrite template to output file
#
( cat ${MAPPING};echo ) | \
    while read line
    do
        if [[ $line =~ "^#" ]]
        then
            echo "Skipping comment line..."
        else
            TOKEN=$(echo $line | cut -d= -f1)
            VAR=$(echo $line | cut -d= -f2)
            if [ -z "${TOKEN}" -o -z "${VAR}" ]
            then
                echo "Skipping empty line... $line"
            else
                VAL="${!VAR}"
                if [ -z "${VAL}" ]
                then
                    echo "error: '${VAR}' is not defined in '${PROPSFILE}'" >&2
                    exit 1
                fi
                sed -i -e "s/${TOKEN}/${VAL}/g" "${OUTFILE}"
            fi
        fi
    done
if [ $? -ne 0 ]
then
    echo "Creation of command file failed"
    exit 1
fi

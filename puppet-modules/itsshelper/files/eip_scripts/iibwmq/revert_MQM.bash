#!/bin/bash
# Takes 3 parameters
# 1: environment name (ie dv1, ps1 etc)
# 2: Fix pack name (ie U8002 or U0004 etc)
# 3: OPTIONAL If = FORCE then no prompt to confirm

env=$1
fixp=$2
force=$3

printusage()
{
  echo "$0 env fixpack"
}

if [ -z "$env" -o -z "$fixp" ] ; then
  printusage
  exit 1
fi

if [ ! -d /opt/$env ] ; then
  echo "$env does not exist"
  printusage
  exit 2
fi

RPMS=$(rpm -qa | grep $env | grep $fixp)
if [ -z "$RPMS" ] ; then
  echo "Can't find that fix pack name"
  printusage
  exit 3
fi

if [ "$force" = "FORCE" ] ; then
  cont="y"
else
  echo "This will remove:"
  echo "$RPMS"
  echo
  read -p "Continue? " cont
fi
if [ "$cont" = "y" -o "$cont" = "Y" ] ; then
  rpm -ev $RPMS
fi

#!/bin/sh

if [[ "$(dirname $0)" == "." ]]; then
SCRIPTROOT=`pwd`
else
SCRIPTROOT=$(dirname $0)
fi

python $SCRIPTROOT/../lib/release.py $*
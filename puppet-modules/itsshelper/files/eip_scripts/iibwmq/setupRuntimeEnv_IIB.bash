#!/bin/sh

ENV=$1
IIB_ADMIN_USER=iibadmin
MQSI_ROOT=/opt/$ENV/iib/server
MQSI_BIN_LOC=${MQSI_ROOT}/bin
su - $IIB_ADMIN_USER  -c "echo \". ${MQSI_BIN_LOC}/mqsiprofile\" >> ~/.bashrc"

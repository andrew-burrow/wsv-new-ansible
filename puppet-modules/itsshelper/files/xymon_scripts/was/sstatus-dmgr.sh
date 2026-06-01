ENV=$1
APP=$2
CMD=$3

/opt/${ENV}/WebSphere/AppServer/profiles/${APP}-${ENV}-Dmgr01/bin/serverStatus.sh ${CMD}

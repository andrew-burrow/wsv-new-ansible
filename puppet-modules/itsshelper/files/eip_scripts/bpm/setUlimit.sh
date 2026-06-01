#!/bin/sh

echo "#########################################################################################"
echo "        START - update parameters to limits.conf"
echo "#########################################################################################"

limits_config_file=/etc/security/limits.conf
#limits_config_file=./limits.conf

lineNumber=$(sed -n '/# End of file/=' $limits_config_file)
line=$(sed -n '/# - stack - max stack size(KB)/=' $limits_config_file)


if [[ ! -z "$lineNumber"  &&  -z "$line" ]];
 then
        sed -i '$ i  # - stack - max stack size(KB)' $limits_config_file
        sed -i '$ i  * soft    stack           32768' $limits_config_file
        sed -i '$ i  * hard    stack           32768' $limits_config_file
        sed -i '$ i  # - nofile - max number of open files' $limits_config_file
        sed -i '$ i  * soft    nofile          65536' $limits_config_file
        sed -i '$ i  * hard    nofile          65536' $limits_config_file
        sed -i '$ i  # - nproc - max number of processes' $limits_config_file
        sed -i '$ i  * soft    nproc           16384' $limits_config_file
        sed -i '$ i  * hard    nproc           16384' $limits_config_file
        sed -i '$ i  # - fsize - maximum file size' $limits_config_file
        sed -i '$ i  * soft    fsize           6291453' $limits_config_file
        sed -i '$ i  * hard    fsize           6291453' $limits_config_file
		
  
fi

echo ""
echo "        END - update parameters to limits.conf"
echo ""

echo "#########################################################################################"
echo "        START - update /etc/security/limits.d/90-nproc.conf"
echo "#########################################################################################"

nproc_config_file=/etc/security/limits.d/90-nproc.conf
#nproc_config_file=./90-nproc.conf

ln=$(sed -n '/nproc/=' $nproc_config_file)

if [ !  -z "$ln" ];
 then
        sed -i -- 's/nproc.*$/nproc    16384/g' $nproc_config_file
  
fi

echo ""
echo "        END - update /etc/security/limits.d/90-nproc.conf"
echo ""

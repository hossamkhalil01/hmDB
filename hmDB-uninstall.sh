##################################################
# this scripts uninstalls the  the project     ###
# you need to run this script in sudo mode.    ###               
##################################################

#!/bin/bash

#check permissions
uId=`id -u`

if [ $uId != 0 ]
then 
    echo Permission Denined! please run the script using sudo command!
    exit 
fi 
scriptPath="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

#remove all scripts from the /usr/bin/hmDBDir if exists
if [ -d "/usr/bin/hmDBdir" ]
then 
    rm -R "/usr/bin/hmDBdir"
fi 


#remove the main script if exists

if [ -f "/usr/bin/hmDB" ]
then 
    rm "/usr/bin/hmDB"
fi 


echo hmDB is uninstalled.
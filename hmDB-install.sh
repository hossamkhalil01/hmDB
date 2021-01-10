######################################################################
# this scripts installs the environment needed to run the project#####
# you need to run this script in sudo mode.                      #####               
######################################################################

#!/bin/bash

#check permissions
uId=`id -u`

if [ $uId != 0 ]
then 
    echo Permission Denined! please run the script using sudo command!
    exit 
fi 
scriptPath="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"


#make all the files executable
chmod +x -R "$scriptPath/hmDBdir/src/"

#Move all required scripts to the /usr/bin/hmDB

#copy the project dirctory

#copy the script to the program dir in usr/bin
cp -R $scriptPath/hmDBdir/ /usr/bin/hmDBdir

#Create the data directory
if [ ! -d "/usr/bin/hmDBdir/data" ]
then 
    mkdir /usr/bin/hmDBdir/data/
    mkdir /usr/bin/hmDBdir/data/DBs
fi 

#copy the main script to the usr/bin
cp $scriptPath/hmDB /usr/bin/hmDB

echo Setup completed.. Enjoy using hmDB!
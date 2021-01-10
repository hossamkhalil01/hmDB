#!/bin/bash

########## Functions ##########

#To validate a string as a name
#(starts with char only and contains number, lower, upper and undrscore with length up to 10 char)
function isNameValid()
{   #Expected argument: Name(string)

    if [[ $1 =~ ^[a-zA-Z]([a-z0-9_A-Z]{0,10}|[a-z0-9_A-Z]{0,10}\$)$ ]] 
    then
        return 0

    #Invalid name
    else 
        return 1
    fi
}
function isArgExist()
{   #Expected argument: variable
    if [ ! -z "$1" ] #doesn't exist
    then 
        return 0
    else 
        return 1
    fi
}
function isArgNotExist()
{   #Expected argument: variable
    if [ -z "$1" ] #doesn't exist
    then 
        return 0
    else 
        return 1
    fi 
}

#Function to validate whether or not a dir or file does exist
function isFound()
{   #Expected arguments: -d or -f (for dir /file) , file/dir Path
    # -d for directory while -f for file
    
    if [ $1 $2 ] #Exists
    then 
        return 0

    else 
        return 1
    fi
}

#Error handling (exception and exit)
function raiseError()
{   #Expected arguments: return code, error message
    # return code: 1 for error and 0 for well executed

    if [ $1 = 1 ]
    then    
        echo $2
        echo "--Try "help" command if you need help.--"
        exit 1
    fi 
}

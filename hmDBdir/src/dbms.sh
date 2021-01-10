#!/bin/bash

########################################################
## This script manages the databases related queries ###
########################################################

# help --> for opening the manual

###########################################################################################
# Available Queries on Databases                                                          #
###########################################################################################
#                                                                                         #
# create database databaseName                                                            #               
# drop database databaseName                                                              #      
# show databases ---> displays all databases                                              #
# use databaseName ---> Activates a database  (makes it ready for table queries)          #      
# close --> closes the current database in use (deactivates the database in use)          #
###########################################################################################


#Include libraries
source src/includes/printTable.sh 
source src/includes/lib.sh

######### Helper Functions##########
function validateDBName
{   #Expected argument: database name

    #Check if the database name is valid
    isNameValid $1

    #raise error if invalid
    raiseError $? "Error: invalid database name."

    return 0
}

########################
### Process Query #####
######################
function procQuery()
{   #Expected argument: query
    #to decide which command to run
    #Queries are case insensitive
    
    if [ -z $1 ] #No argument is passed
    then 
        return 1
    fi 

    #Help command 
    if [ $1 = "help" ] && [ -z "$2" ]
    then 
        #display the manual if found
        if [ -f $helpPath ]
        then
            printf "\n\n"
            more $helpPath
            printf "\n\n"
            
        else 
            raiseError 1 "Error: Manual is missing."
        fi
        return 0 
    fi 

    #Database exclusive commands:
    #use dbName , close [None]
    if [ ${1,,} = use ]
    then 
        shift 
        useDB $@        
        raiseError $? "Unknown database."
        echo "Database changed."

    elif [ ${1,,} = close ]
    then 
        shift 
        closeDB $@ 
        raiseError $? "Can't close database: No database is opened!"
        echo "Database closed successfully."

    elif [ "${1,,} ${2,,}" = "show databases" ]
    then 
        shift 2
        showDBs $@
    
    elif [ -z $2 ]
    then 
        raiseError 1 "Error: Invalid query syntax." 
    
    #Database commands (that are identified by (database))
    elif [ ${2,,} = database ]
    then 
        
        case ${1,,} in 
        create)
            shift 2
            createDB $@
            raiseError $? "Can't create database: database exists"
            echo "Database created successfully."
            ;;
        drop)
            shift 2
            dropDB $@
            raiseError $? "Can't drop database: database doesn't exist"
            echo "Database dropped successfully."
            ;;
        *)
            raiseError 1 "Error: Invalid query syntax." 
            ;;

        esac 

    else #Not a valid db query

        initTableCmd "$@"
        raiseError $? "Error: No database selected"  
 
    fi 

    return 0
}

#########################
### Run table command ###
#########################

initTableCmd()
{   #Expected arguments: table command

    if [ -z $currDB_path ] #if there's not an opened DB
    then 
        return 1
    else  
        source ./src/table_mang.sh "$@"
    fi

    return 0
}

########################
##### DB Quieries #####
######################

function createDB ()
{   #Expected arguments: database Name (only)
    
    #Check if the right number of arguments is passed
    isArgExist $1 
    raiseError $? "Error: Invalid syntax database name missing."

    isArgNotExist $2 
    raiseError $? "Error: Invalid syntax Too many arguments."

    #Check if the database name is valid
    validateDBName $1

    #Check if the database exists!
    isFound -d "$dataPath$1"

    if [ $? -eq 0 ] #it exsits
    then 
        return 1 
    
    else 
        mkdir "$dataPath$1" 
        return 0
    fi
    
}
function dropDB ()
{   #Expected arguments: Database Name (only)

    #Check if the right number of arguments is passed
    isArgExist $1 
    raiseError $? "Error: Invalid syntax database name missing."

    isArgNotExist $2 
    raiseError $? "Error: Invalid syntax too many arguments."

    #Check if the database name is valid
    validateDBName $1

    #Check if the database is in use
    if [ ! -z "$currDB_name" ] #There is an Opened DB
    then 
        if [ "$currDB_name" = "$1" ] #Opened DB
        then 
            raiseError 1 "Can't drop database: database is in use"
        fi
    fi

    #Check if the table exists!
    isFound -d "$dataPath$1"

    if [ $? -eq 0 ] #it exsits
    then 
        rm -r "$dataPath$1"
        return 0

    else 
        return 1
    fi
}
function showDBs ()
{   #Expected arguments: None
    
    #Check that there are no arguments passed
    isArgNotExist $1 
    raiseError $? "Error: Invalid syntax too many arguments."
    
    #List all directories

    #output in temp file 
    echo "Available Databases" > $tempPath
    ls $dataPath >> $tempPath
    
    #print the talbe of tables
    printTable ":" "$(cat $tempPath )"

    #remove the temp file
    rm $tempPath

    return 0
}
function useDB()
{   #Expected arguments: Database Name (only)

    #Check if the right number of arguments is passed
    isArgExist $1 
    raiseError $? "Error: Invalid syntax database name missing."

    isArgNotExist $2 
    raiseError $? "Error: Invalid syntax too many arguments."

    #Check if the database name is valid
    validateDBName $1

    #Check if the database exists!
    isFound -d "$dataPath$1/"

    if [ $? -eq 0 ] #it exsits
    then 
        currDB_path="$dataPath$1/" #the database path
        currDB_name="$1"
        return 0

    else  #Doesn't exist 
        return 1
    fi 
}
function closeDB()
{   #Expected arguments: None

    #Check if the right number of arguments is passed
    isArgNotExist $1 
    raiseError $? "Error: Invalid syntax too many arguments."

    #Check if there's an opened DB
    if [ -z "$currDB_name" ]
    then 
        return 1
    
    else 
        currDB_path="" #the database path
        currDB_name=""
        return 0
    fi
}

#######################
### Save temp data ####
#######################
function saveEnv()
{   #Expected arguments: None

    echo "$currDB_name" > "$infoPath"
    echo "$currDB_path" >> "$infoPath"

    return 0
}

##### Main #######
function main ()
{   #Expected arguments: query 

    #Init temp file path for processing
    tempPath="$dbTempPath""temp"

    #Process the input query
    procQuery $@
    raiseError $? "Error: No query specified"

    #save variables
    saveEnv
}

#Call main function
main "$@"

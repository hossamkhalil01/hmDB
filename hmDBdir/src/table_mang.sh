#!/bin/bash

#####################################################
## This script manages the tables related queries ###
#####################################################
###########################################################################################
# Available Queries on Tables                                                             #
###########################################################################################
# DDLs                                                                                    #      
######                                                                                    #  
# show tables --> list all tables in the DB                                               #               
# describe table tableName --> display the difinition of the table                        #      
# create table tableName col1Name col1_dType [col1_pk], col2_nanme col2_dType [col2_pk],..#
# drop table tableName                                                                    #      
###########################################################################################
# DMLs                                                                                    #      
######                                                                                    #      
# insert into tableName values col1_value col2_value col3_value ...                       #  
# delete from tableName [where condition] --> where colName = value                       #  
# select colName/all (for all cols) [where condition] --> where colName = value           #  
# update tableName set colName = newValue [where condition] --> where colName = value     #  
###########################################################################################


######### Helper Functions##########
function validateName
{   #Expected argument: table name

    #Check if the table name is valid
    isNameValid $1

    #raise error if invalid
    raiseError $? "Error: Invalid name."

    return 0
}
function validateDtype()
{   #Expected arguments: datatype

    if [ -z $1 ] #doesn't exist 
    then 
        raiseError 1 "Error: Invalid datatype."
        return 1 
    fi 

    if [ ${1,,} = int ] || [ ${1,,} = str ]
    then 
        return 0 #valid datatype
    
    else 
        #raise error if invalid
        raiseError 1 "Error: Invalid datatype."
        return 1
    fi 
}
function isConstrValid()
{   #Expected arguments: constraint(pk or nothing)
    if [ -z $1 ]
    then 
        echo none
        return 0
    fi

    if [ ${1,,} = pk ]
    then 
        echo pk
        return 0
    else 
        return 1
    fi
}
function insertRow()
{   #Expected arguments: file path, row 

    local filePath="$1"
    shift

    if [ -z "$1" ]
    then 
        return 1
    fi 

    local tmpStr="$1"
    shift 

    for element in $@  #loop through the rows
    do 
        tmpStr=$tmpStr:$element     
    done

    #append the string
    echo $tmpStr >> $filePath   
    
    return 0
}
function retreiveRow()
{   #Expected arguments: filePath, lineNumber
    
    echo $(head -n"$2" "$1" | tail -n1)

    return 0
}
function isPkUnique()
{   #Expected argument: filePath, column number, col value

    local filePath=$1
    local fieldNo=$2
    local pkValue=$3

    #Check if the pk is unique 
    local isUniq=`sed '1,3d' "$filePath" |\
    awk -F: -v value="$pkValue" -v fieldNo="$fieldNo" '{if($(fieldNo) == value){print "1"}}'`

    if [ -z $isUniq ] #not found
    then 
        isUniq=0
    fi 

    return $isUniq
}
function insertRecord()
{   #Expecsted arguments: filePath, row values

    local filePath=$1
    shift

    #get the number of columns in the file
    local colCount=`awk -F':' '{print NF; exit}' $filePath`

    #Check if the number of columns is out of boundries
    if [ $# -gt $colCount ]
    then 
        raiseError 1 "Invalid insertion: Number of values out of boundry."
    fi 


    #read columns data type definition in an array
    declare -a local dtypeArr
    local dTypeRow=2

    local row=`retreiveRow $filePath $dTypeRow`
    readarray -d : -t dtypeArr <<< $row


    #read columns constraint definition in an array
    declare -a local constrArr
    local constrRow=1

    local row=`retreiveRow $filePath $constrRow`
    IFS=':' read -ra constrArr <<< $row
 

    local numRegex='^[0-9]+$'
    local let indx=0
    local let pkField

    declare -a local recordArr
    IFS=' ' read -ra recordArr <<< "$@"

    #loop through the columns of the table
    for constr in "${constrArr[@]}"
    do 

        #Check if the value doesn't exist
        if [ -z ${recordArr[$indx]} ] || [ ${recordArr[$indx],,} = null ] 
        then 
            #check if the constraint is pk
            if [ $constr = pk ]
            then 
                raiseError 1 "Error: Primary key column cannot be null"
            else 
                recordArr[$indx]=NULL
            fi 
        
        #the value exists
        else  

            #validate datatype
            if [ ${dtypeArr[$indx]} = int ] && \
            [[ ! ${recordArr[$indx]} =~ $numRegex ]]
            then 
                raiseError 1 "Error: Datatype mismatch."
            fi 

            #validate primary key
            if [ $constr = pk ]
            then 
                let pkField=$indx+1
                isPkUnique $filePath $pkField ${recordArr[$indx]}
                raiseError $? "Error: Primary key violation."
            fi 
        fi
        let indx=$indx+1
    done 

    
    #Insert the constructed record
    insertRow $filePath ${recordArr[@]}
    
    return 0 #valid datatype
}
function isColExist()
{   #Expected arguments: filePath, colName
    #returns the field number of the col (if existed)

    local filePath=$1
    local targetCol=$2
    local colNameRow=3
    declare -a local colArr
    
    #Fetch the cols names
    local row=`retreiveRow "$filePath" "$colNameRow"`
    readarray -d : -t colArr <<< $row

    #check if the colName exists in the array
    local found=1
    local let fieldNo=1 

    for col in ${colArr[@]} 
    do 
        if [ $col = $targetCol ] #Found
        then 
            found=0
            echo $fieldNo

            break
            
        fi 
        let fieldNo=$fieldNo+1
    done 

    return $found

}
function getCellValue()
{   #Expected arguments: filePath, rowNumber, colNumber

    #get the cell value 
    echo $(sed -n "$2"p $1 | cut -f"$3" -d:)
    return 0
}
function getRowNumber()
{   #Expected arguments: filePath, colNumber, value , targetValue

    local filePath=$1
    local colNum=$2
    local targetValue=$3
    
    #extract the targeted column values
    local num=$(cut -d: -f$colNum "$filePath" | sed '1,3d' |\
    awk -F: -v target="$targetValue" \
    'BEGIN{count=1}{if($1 == target){print count} {count++}}')

    #Was not found
    if [ -z "$num" ]
    then 
        return 1
    else 

        echo $num
        return 0
    fi

}
function displayColumn()
{   #Expected arguments: filePath, colNum

    local filePath=$1
    shift 

    if [ $1 = "all" ] #display all columns
    then     
        #Display the table and execlude the definition rows
        printTable ':' "$(sed '1,2d' $filePath)"
        
    else #display one column
    
        cut -d: -f"$1" $filePath | printTable ':' "$(sed '1,2d' )"
    fi 

    return 0
}
function processWhereCond()
{   #Expected arguments: where colName = value

    if [ ! ${1,,} = where ] #invalid syntax
    then 
        raiseError 1 "Error: Invalid syntax."
        return 1
    fi 

    shift 

    #check if the condition exists (colName operator value)
    if [ "$#" -ne 3 ] 
    then 
        raiseError 1 "Error: Invalid syntax."
    fi 

    # Check if the column name is valid 
    validateName $1

    #Check if the column name exist
    local fieldNo
    fieldNo=`isColExist $filePath $1`
    raiseError $? "Error: Unknown column."

    #get datatype of this column  
    local dType=`getCellValue $filePath 1 $fieldNo`

    shift   

    local numRegex='^[0-9]+$'
    
    #Check the operator is equal
    if [ ! $1 = "=" ]
    then 
        raiseError 1 "Error: Invalid syntax."
    fi 

    #check if the value is int if the datatype is int
    if [ $dType = int ] && [[ ! $2 =~ $numRegex ]]
    then 
        raiseError 1 "Error: Invalid datatype."
    fi 

    shift 

    #Check the value 
    local targetValue=$1

    #Search for the record number
    local targetRowNumber
    targetRowNumber=`getRowNumber $filePath $fieldNo $targetValue`
    raiseError $? "Error: Record doesn't exist."
    
    #convert to array
    IFS=' ' read -ra rowNumArr <<<"$targetRowNumber"

}
function updateTable ()
{   #Expected argumets: filePath, colNum, newValue, arr of row numbers or (all for all)

    local filePath=$1 
    local colNum=$2 
    local newValue=$3 

    shift 3
    
    if [ $1 = all ] #update all rows
    then 
        #update all records to the temp file
        awk -F: -v value=$newValue -v fieldNo=$colNum 'BEGIN{OFS=":"}\
        {if(NR >3){$fieldNo = value};print $0}' $filePath > $tempPath

        #save changes and exit 
        mv $tempPath $filePath
        
        return 0
    fi 


    #read the array of rows to be updated
    declare -a local rowNumArr 
    readarray -d" " -t rowNumArr <<< "$@"

    local let rowNumber

    #update only the rows in the array
    for rowNum in ${rowNumArr[@]} 
    do 
        #update the row Number(shifted by 3 for def lines)
        let rowNumber=$rowNum+3

        #update the given record to the temp file
        awk -F: -v rowNumber=$rowNumber -v value=$newValue -v fieldNo=$colNum 'BEGIN{OFS=":"}\
        {if(NR == rowNumber){$fieldNo = value};print $0}' $filePath > $tempPath

        #save changes
        mv $tempPath $filePath

    done 

    return 0

}

########################
### Process Query #####
######################
function procQuery()
{   #Expected arguments: query on tables
    #to decide which command to run
    #queries are case insensitive

    #DDL queries on table

    if [ "${1,,} ${2,,}" = "show tables" ]
    then 
        shift 2 
        showTables $@
    
    elif  [ "${1,,}" = "describe" ]
    then 
        shift 
        describeTable $@
        raiseError $? "Error: Table doesn't exist."
    
    elif [ -z $2 ]
    then 
        raiseError 1 "Error: Invalid query syntax." 
    
    #table commands (that are identified by table keyword)
    elif [ ${2,,} = table ]
    then 
        case ${1,,} in 
        create)
            shift 2
            createTable "$@"
            raiseError $? "Error : Table already exists"
            echo "Table created successfully."
            ;;    
        drop)        
            shift 2
            dropTable $@
            raiseError $? "Error: Table doesn't exist"
            echo "Table dropped successfully."
            ;;

        *)
            raiseError 1 "Error: Invalid query syntax." 
            ;;
        esac
    
    #DMLs 
    elif [ ${1,,} = "select" ]
    then
        shift 
        selectQuery $@
        raiseError $? "Error: Unknown table."

    elif [ "${1,,} ${2,,}" = "insert into" ]
    then
        shift 2
        insertQuery $@ 
        raiseError $? "Error: Unknown table."
        echo "Record inserted successfully."
      
    elif [ "${1,,} ${2,,}" = "delete from" ]
    then 
        shift 2
        deleteQuery $@ 
        raiseError $? "Error: Unknown table."
        echo "Records deleted successfully."

    elif [ ${1,,} = update ]
    then 
        shift 
        updateQuery $@
        raiseError $? "Error: Unknown table."
        echo "Record updated successfully."

    else #Not a valid table query
        raiseError 1 "Error: Invalid query syntax."  
    fi 

    return 0
}

#########################
##### DDL Quieries #####
#######################
function showTables()
{   #Expected arguments: (None)

    #Check that there are no arguments passed
    isArgNotExist $1 
    raiseError $? "Error: Invalid syntax too many arguments."
    
    #List all files (tables)
    #output in temp file 
    echo "Tables in ($currDB_name)" > $tempPath
    ls $currDB_path >> $tempPath
    
    #print the talbe of tables
    printTable ":" "$(cat $tempPath)"

    #remove the temp file
    rm $tempPath
    
    return 0
}
function describeTable()
{   #(Not Complete)Expected arguments: tableName(only)

    #Check if the right number of arguments is passed
    isArgExist $1 
    raiseError $? "Error: Invalid syntax table name missing."

    isArgNotExist $2 
    raiseError $? "Error: Invalid syntax too many arguments."

    #Check if the table name is valid
    validateName $1

    #Check if the table exists!
    local filePath=$currDB_path$1
    isFound -f $filePath

    if [ $? -eq 0 ] #exists 
    then 
        #Display the table definition rows
        echo $1
        printTable ':' "$(sed -n '1,3p' $filePath)"
        return 0
    
    else 
        return 1
    fi
}
function createTable()
{   #Expected arguments: tableName, "col1Def" [colsDef]
    #columns def syntax: "colName col_dType [col constraint]"

    #Check if the right number of arguments is passed
    isArgExist $1 
    raiseError $? "Error: Invalid syntax table name missing."

    isArgExist $2 
    raiseError $? "Error: Invalid syntax columns definition missing."

    #Check if the table name is valid
    validateName $1

    #Check if the table exists
    local filePath="$currDB_path$1"

    isFound -f $filePath

    if [ $? -eq 0 ] #it exsits
    then 
        return 1 
    fi 

    shift 
    
    #process column definition
    declare -a local colDef 

    #Decalre arrays to store the rows  
    declare -a local nameArr
    declare -a local dtypeArr
    declare -a local constrArr
    declare -a local row 

    local currConstr
    local pkFlag 

    #Extract columns definitions
    IFS=',' read -ra colDef <<< "$@"

    #loop through each column def
    for col in "${colDef[@]}"
    do
        #check the coloumn definition
        IFS=' ' read -ra col <<< "$col"

        #Check the column name
        validateName "${col[0]}"
        
        #Check the data type 
        validateDtype "${col[1]}"

        #validate constraint
        currConstr=`isConstrValid "${col[2]}"`
        raiseError $? "Error: Invalid constraint."

        #Check if the pk was already inserted
        if [ $currConstr = pk ]
        then 
            if [ "$pkFlag" = 1 ]
            then
                raiseError 1 "Error: Multiple primary key defined"
            else 
                pkFlag=1
            fi 
        fi 

        #add the valid column definition to the array
        nameArr+=(${col[0]})
        dtypeArr+=(${col[1],,})
        constrArr+=(${currConstr,,})

    done

    #Create table file
    touch "$filePath"

    #insert the definition rows into the table file
     
    #insert the definition rows

    #constraint in the first row
    insertRow $filePath ${constrArr[@]}
    #datatype in the second row
    insertRow $filePath ${dtypeArr[@]}
    #column name in the third row
    insertRow $filePath ${nameArr[@]}

    return 0
}
function dropTable()
{   #Expected arguments: Database Name (only)
    #deletes the entire table 

    #Check if the right number of arguments is passed
    isArgExist $1 
    raiseError $? "Error: Invalid syntax table name missing."

    isArgNotExist $2 
    raiseError $? "Error: Invalid syntax too many arguments."

    #Check if the table name is valid
    validateName $1

    #Check if the table exists
    local filePath="$currDB_path$1"

    isFound -f $filePath

    #delete if it exists
    if [ $? -eq 0 ] #it exsits
    then 
        rm $filePath
        return 0

    else  #Doesn't exist 
        return 1
    fi 
}

#########################
##### DML Quieries #####
#######################
function insertQuery()
{   #Expected arguments: tableName, values , rows array
    #query syntax: insert into table values col1Value col2Value..
    #row syntax: col1_value col2_value, [other rows] ...

    #Check if the right number of arguments is passed
    isArgExist $1 
    raiseError $? "Error: Invalid syntax table name missing."

    isArgExist $2 
    raiseError $? "Error: Invalid syntax."

    #Check syntax
    if [ ! ${2,,} = values ]
    then 
        raiseError 1 "Error: Invalid syntax."
    fi 

    #Check if the table name is valid
    validateName $1

    #Check if the table exists
    local filePath="$currDB_path$1"

    isFound -f $filePath

    if [ $? -eq 1 ] #it doesn't exsit
    then 
        return 1 
    fi 
    
    shift 2

    #Check if values are entered
    if [ -z "$1" ]
    then 
        raiseError 1 "Error: Empty values."
    fi

    # read multiple insertion 
    declare -a local insertionArr 
    IFS=',' read -ra insertionArr <<< "$@"

    #Check the datatype for each element
    for record in "${insertionArr[@]}"
    do 
        if [ -z "$record" ] #break if there's nothing left
        then 
            break 
        fi
        insertRecord $filePath "$record"
    done 

    return 0
}
function deleteQuery()
{   #Expected arguments: tableName, [where , colName , operator, value]
    #query syntax: delete from tableName where colName = value

    #Check if the right number of arguments is passed
    isArgExist $1 
    raiseError $? "Error: Invalid syntax table name missing."

    #Check if the table name is valid
    validateName $1

    #Check if the table exists
    local filePath="$currDB_path$1"

    isFound -f $filePath

    if [ $? -eq 1 ] #it doesn't exist
    then 
        return 1 
    fi

    shift 

    #Check if where condition exists
    if [ -z $1 ] #empty the table
    then 
        #save the definition
        sed -n '1,3p' > $tempPath $filePath
        mv $tempPath $filePath
        return 0
    fi 

    #Delete based on condition

    declare -a rowNumArr
    
    processWhereCond "$@"
    
    #Construct the new table (in temp file)

    #save the definition
    sed -n '1,3p' $filePath > $tempPath 

    #delete the difinition lines
    sed '1,3d' -i $filePath 

    local let initCount=0
    local let lineNum=0

    #delete each line
    for rowNum in "${rowNumArr[@]}"
    do 
        let lineNum=$rowNum-$initCount
        sed "$lineNum"d -i $filePath  
        let initCount=$initCount+1
    done

    #move the constructed table to the temp file
    sed -n p $filePath >> $tempPath

    #save the new values
    mv $tempPath $filePath

    return 0
}
function selectQuery()
{
    #Expected arguments: colName(all for all), From, TableName, [where, colName, operator, value]
    #query syntax: select colName from tableName where colName = value
    
    #Check if the right number of arguments is passed
    isArgExist $1 
    raiseError $? "Error: Invalid syntax column name missing."

    #Check the number of arguments
    if [ "$#" -lt 3 ]
    then 
        raiseError 1 "Error: Invalid syntax."
        return 1
    fi 

    #Check if the table name is valid
    validateName $3

    #Check if the table exists
    local filePath="$currDB_path$3"

    isFound -f $filePath

    if [ $? -eq 1 ] #it doesn't exist
    then 
        return 1 
    fi

    local fieldNo
    #check the column name 
    if [ ${1,,} = "all" ] #Select all columns
    then 
        fieldNo="all"

    else #Check the column name 
        
        # Check if the column name is valid 
        validateName $1

        #Check if the coloumn name exist
        fieldNo=`isColExist $filePath $1`
        raiseError $? "Error: Unknown column."
    
    fi

    shift 
    
    #Check the syntax
    if [ ! ${1,,} = from ] #invalid syntax
    then 
        raiseError 1 "Error: Invalid syntax."
        return 1
    fi 

    shift 2

    #check if where condition exists

    #Check if where condition exists
    if [ -z $1 ] #no condition (display all)
    then 
        displayColumn $filePath $fieldNo
        return 0
    fi 
    
    #select based on condition
    declare -a rowNumArr
    processWhereCond "$@"

    #Construct the new table to be selected (in temp file)
    
    #move the data to be selected in a temp file
    sed -n '1,3'p $filePath > $tempPath

    local let lineNum=0

    #Move each line
    for rowNum in "${rowNumArr[@]}"
    do 
        #Shift for the definition rows
        let lineNum=$rowNum+3

        #append the line to the new table
        sed -n "$lineNum"p $filePath  >> $tempPath
    done

    #Display the new table
    displayColumn $tempPath $fieldNo

    #remove the temp data 
    rm $tempPath 

    return 0

}
function updateQuery()
{   #Expected arguments: tableName, set , colName, = , newValue , [where, colName, operator, value]
    #query syntax: update tableName set colName = newValue where colName = value

    #Check if the right number of arguments is passed
    isArgExist $1 
    raiseError $? "Error: Invalid syntax table name missing."

    isArgExist $2 
    raiseError $? "Error: Invalid syntax."

    #Check syntax
    if [ ! ${2,,} = set ]
    then 
        raiseError 1 "Error: Invalid syntax."
    fi 
    
    #Check if the table name is valid
    validateName $1
    
    #Check if the table exists
    local filePath="$currDB_path$1"

    isFound -f $filePath

    if [ $? -eq 1 ] #it doesn't exist
    then 
        return 1 
    fi

    shift 2

    #Check the update condition

    if [ "$#" -lt 3 ]
    then 
        raiseError 1 "Error! Invalid syntax."
    fi 

    #Check the column name is valid
    validateName $1

    #Check if the column name exist
    local newFieldNo
    newFieldNo=`isColExist $filePath $1`
    raiseError $? "Error: Unknown column."

    #get datatype of this column  
    local dType=`getCellValue $filePath 2 $newFieldNo`

    #get the constraint
    local constr=`getCellValue $filePath 1 $newFieldNo`
    shift  

    local numRegex='^[0-9]+$'
    
    #Check the operator is equal
    if [ ! $1 = "=" ]
    then 
        raiseError 1 "Error: invalid syntax."
    fi 

    #check if the value is int if the datatype is int
    if [ $dType = int ] && [[ ! $2 =~ $numRegex ]]
    then 
        raiseError 1 "Error: Invalid datatype."
    fi 

    #store the new value
    local newValue=$2

    if [ ${newValue,,} = null ] #Check if the new value is null
    then 
        newValue=NULL
    fi 

    #check if the update is on the primary key
    if [ $constr = pk ]
    then 
       #Check if the new value is null 
        if [ $newValue = NULL ]
        then 
            raiseError 1 "Error: Primary key column cannot be null"
        fi 
        isPkUnique $filePath $newFieldNo $newValue
        raiseError $? "Error: Primary key violation."
    fi 

    shift 2

    #Check if where condition exists
    if [ -z $1 ] #no condition (update all)
    then 
        #trying to update all pk values with the same value
        if [ $constr = pk ]
        then 
            raiseError 1 "Error: Primary key violation."
        fi

        #update all records in the table
        updateTable $filePath $newFieldNo $newValue "all"
        return 0
    fi 

    #Update based on condition
    declare -a rowNumArr
    processWhereCond "$@"

    #update the selected rows of the table
    updateTable $filePath $newFieldNo $newValue "${rowNumArr[@]}"

    return 0
}

##### Main #######
function main ()
{   #Expected arguements: table query statments

    #Process the query
    procQuery "$@"
}

#Call main function
main "$@"

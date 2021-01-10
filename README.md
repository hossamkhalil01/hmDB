#Project Name
database management search engine


#Description
This is a basic Database Management System project in Bash script
you can create new database,delete specific database,list all available databse
and select specific database.
you can create tables and insert columns into the table with it's datatype (String or integer ),delete specific table,list all available tables inside a database,
open specific table and select all records from this table,delete specific record from table
and update certain record in table

#files

1-lib.sh:this script is shared functions that are used throughout the scripts To validate a string as a name 

lib.sh functions:
-isNameValid(): validate name it must starts with char only and contains number, lower, upper and undrscore with length up to 10 char.Expected argument: Name(string)

-isFound():Function to validate whether or not a dir or file does exist.
    --Expected arguments: -d or -f (for dir /file) , file/dir Path
        (-d for directory while -f for file)

-raiseError():Error handling (exception and exit)
    --Expected arguments: return code, error message
    return code: 1 for error and 0 for well executed
-isArgExist():check if arguments exists or not 
    --Expected argument: variable

-isArgNotExist():check if arguments exists or not 
    --Expected argument: variable

2-dbms.sh:this script is used to manage database functions

dbms.sh functions:
-validateDBName():Check if the database name is valid
    --Expected argument: database name

-procQuery():to decide which command to run
    --Expected argument: query (create,drop,use,show databases,help,close)

-initTableCmd():check if there are an opened DB and then calls table_mang.sh script to initialize table commands
    --Expected arguments: table command

-createDB ():create new database
    --Expected arguments: database Name

-dropDB():function to delete existing database
    --Expected arguments: databaseName

-showDBs ():function to list all availabe databases it expects no arguments

-closeDB():function to close opend database it expects no arguments

-useDB():function to open exsisting database
    --Expected arguments: Database Name



3-table_mang.sh:this scipt is used to manage functions of the tables 

table_mang.sh functions:

-validateName(): Check if the table name is valid
    --Expected arguments: table name

- validateDtype():function to validate datatype of each column
    --Expected arguments:  datatype

-isConstrValid(): to validate column constrains
    --Expected arguments: constraint(pk or nothing)

-insertRow():function to insert records in a table as a columns separated by colon
Expected arguments: file path, array of coloums 

-isPkUnique():this function check if the primary key is unique or not and return 1 if false ,0 if true
    --Expected argument: filePath, column number, col value

-validateCol_def():function to validate column definition ,it's name ,data type and constrain
    --Expected arguments: colName datatype [constraint]
coloumn defination string (separted by spaces)

-sortCols():function to sort columns using primary key index
this function check if there are index on the table or not if yes it check if this index in the first column or not if not it make the primary key index in the first column
    --Expected arguments: primary key index

-createTable():function to create table
at first the function check the table exists or not,then it calls validateCol_def function to validate columns definition from arguments and check that there is only one primary key in each table and then calls sortCols to make primary key in the first column then it calls insertRow function to add this columns on the table
this function check first
    --Expected arguments: tableName, {columns}
    columns def syntax: "col1_name col1_dtype col1_constraint" "col2 col2 col2" ...
    
-deleteTable():this function check if the table exists or not if yes and the deleted option is passed (-d) it delete the table with it's definition other wise delete the records of table only anf keep the definition of the table
    --Expected arguments: tableName, [optional argument](-d)

-listTables():this function check if there is tables in the selected database or not if yes it list all tables,expected no arguments

-dispTable():this function check if the table exist or not ,if yes it prints all records in this table
    --Expected arguments:Table Name

-openTable():this function check if the table exists or not ,if yes it open this table
    --Expected arguments:Table Name

-retreiveRow():this function used to get specific records
    --Expected arguments: filePath, lineNumber


-procRow():this function check datatype of each element for each row entered to the table
    --Expected arguments: filePath, row values

-getCellValue():get the cell value 
    --Expected arguments: filePath, rowNumber, colNumber

 -getRowNumber():this function extract the targeted column values and retrun row number of specific given value
    --Expected arguments: filePath, colNumber, value , targetValue

-insertRecord():this function check if the table exists if yes it calls  procRow function to check the datatype of each row then calls isPk_unique function to check if the primary key uniuqe or not then it insert rows int table
    --Expected arguments: tableName, {coloumns}
    coloumns def syntax: "col1_value col2_value" ...

-isCol_exist():this function check if the column name exist in the table or not and return 1 if false,0 if true
    --Expected arguments: filePath, colName

-displayColumn():Display the table and execlude the definition rows
    --Expected arguments: filePath, colNum

-processWhereCond():check if the condition exists (colName operator value) and save the rownumber of the record
    --Expected arguments: where colName = value

-updateTable():update all records of the table when update command doesn't include where statment
    --Expected argumets: filePath, colNum, newValue, arr of row numbers or (all for all)

-procQuery():to decide which commands to run DDL or DML
    --Expected arguments: query on tables

-showTables():Check that there are no arguments passed and List all available tables
    --Expected arguments: (None)

-describeTable():Display the table definition rows
    --Expected arguments: tableName(only)

-createTable():create new table
    --Expected arguments: tableName, "col1Def" [colsDef],
     columns def syntax: "colName col_dType [col constraint]"

-dropTable():deletes the entire table 
    --Expected arguments: tableName

-insertQuery():to insert new row values
    --Expected arguments: tableName, values , rows array

-deleteQuery(): check if where condition exist or not if yes delete specific rows else delete all recordes
    --Expected arguments: tableName, [where , colName , operator, value]

-selectQuery():check the colname if it is specific column or all keyword to display all recordes and check if where condition exist or not if yes it select specific rows depends on the condition else it diplay all recordes
    --Expected arguments: colName(all for all), From, TableName, [where, colName, operator, value]

-updateQuery():update recordes depend on where condition
    --Expected arguments: tableName, set , colName, = , newValue , [where, colName, operator, value]

4-printTable.sh :We use this library to help us in printing tables like mysql tables format

5-hmDB-install.sh:this scripts installs the environment needed to run the project you need to run this script in sudo mode

6-hmDB-uninstall.sh: this scripts uninstalls the  the project you need to run this script in sudo mode. 

7-hmDB:This script establishes the connection for your setuped database ,Needs to be ran with sudo permission 

#how to use this program

1- you need to run hmDB-install.sh script in sudo mode to installs the environment needed tosetup and run the project

2-then you need to run hmDB script in sudo mode to establishe the connection to your setuped database program, 

    -if you want to o establis connection in interactive mode use this command: hmDB connect -it
    -if you want to establish connection in one command mode use this command : hmDB connect


3-create your databases 

    -you can create more than one database
    -database quieres are case insensitive (ex you can write create database databaseName or CREATE DATABASE databasename ,use databasename or USE databasename)
    -create database command : create database databaseName
    -drop database command : drop database databaseName
    -show all databases command :show databases
    -close opend database command : close

4-create your tables on a selected database
    
    -tables quieres are case insensitive 
    -any string must not include space separator, tables names , columns names and columns values names if there names separated by space it will give you invalid arguments 
    -create table command :  create table tableName col1Name col1_dType [col1_pk], col2_nanme col2_dType [col2_pk],..
    -display the difinition of the table : describe TableName 
    -list all tables in the DB :  show tables
    -drop existing table command : drop table tableName

5-create your Data Manipulation commands

    -any string must not include space separator
    -all arguments of each command must be separated by space 
    -in insert statement to separate mutliple row values use comma (,)
    -insert row values into specific table :  insert into tableName values record1Values(col1_value col2_value col3_value), record2Values, ....
    -select data from specific table command : select colName/all from tableName [where condition] --> where colName = value
    -delete table or delete specific rows commands : delete from tableName [where condition] --> where colName = value 
    -update recordes on the table command : update tableName set colName = newValue [where condition] --> where colName = value 

#ready to use 

-you can use existing created database called hossam in DBs directory and it contains example for created table ,without setup the database 
-you just run sudo ./hmDB connect -it and use it 



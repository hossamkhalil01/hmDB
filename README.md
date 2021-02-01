# hmDB
---

![demo](https://github.com/hossamkhalil01/hmDB/images/overview.gif)

hmDB is a simple database engine designed using bash script for learning puroses, this engine can perform all basic database commands with a mySQL like syntax.

hmDB simulates the working of the basic operations for a DBMS (Database management system) and can perform multiple tasks such as creating and deleting databases or tables, as well as performing operatins on the tables created.

---
## Table of Contents

<!-- TOC -->
- [Description](#description)
- [Installation](#installation)
- [How to Use](#how-to-use)
  - [One Command Mode](one-command-mode)
  - [Interactive Mode](interactive-mode)
- [Features](features)
- [Dependencies](#dependencies)
- [Limitations](#limitations)
- [Possible Improvements](#possible-improvements)
- [Motivation](#motivation)
<!-- /TOC --->

---
## Description

The project consists of three main scripts:

- [hmDB](https://github.com/hossamkhalil01/hmDB/blob/main/hmDB): that is the main script that's the interface for the user.

- [dbms.sh](https://github.com/hossamkhalil01/hmDB/blob/main/hmDBdir/src/dbms.sh) : inside the [hmDBdir/src](https://github.com/hossamkhalil01/hmDB/blob/main/hmDBdir/src) directory that is responsible for all database related commands.

-  [table_mang.sh](https://github.com/hossamkhalil01/hmDB/blob/main/hmDBdir/src/table_mang.sh): inside the [hmDBdir/src](https://github.com/hossamkhalil01/hmDB/blob/main/hmDBdir/src) directory that is responsible for the table related commands.

along with two helper scripts inside the [hmDBdir/src/includes](https://github.com/hossamkhalil01/hmDB/tree/main/hmDBdir/src/includes) directory:

- [lib.sh](https://github.com/hossamkhalil01/hmDB/blob/main/hmDBdir/src/includes/lib.sh): A script that contains helpfull functions that are used multiple times in different scripts.
- [printTable.sh](https://github.com/hossamkhalil01/hmDB/blob/main/hmDBdir/src/includes/printTable.sh): A library that is used to create the table shape when printing the data in the terminal.

##### Note:

the printTable.sh script is referenced from the [linux-cookbooks](https://github.com/gdbtek/linux-cookbooks/blob/master/libraries/util.bash) repository.

The reposatory has a sample database already created for testing can be found inside the [hmDBdir/data/DBs](https://github.com/hossamkhalil01/hmDB/tree/main/hmDBdir/data/DBs) directory.

there is also a created table inside this database called [student](https://github.com/hossamkhalil01/hmDB/tree/main/hmDBdir/data/DBs/hossam/student) , so that it can be used for illustartion purposes.


---
## Installation

First Clone the project in your working directory.
```bash
git clone https://github.com/hossamkhalil01/hmDB
```
or download the zipped file and unzip it in your working directory.


change your working directory to the hmDB directory, then just run the [hmDB-install.sh](https://github.com/hossamkhalil01/hmDB/blob/main/hmDB-install.sh) script and it will take care of everything.

```bash
sudo . hmDb-install.sh
```

you can also uninstall and remove any directories or files made by hmDB using the [hmDB-uninstall.sh](https://github.com/hossamkhalil01/hmDB/blob/main/hmDB-uninstall.sh) script.

```bash
sudo . hmDb-uninstall.sh
```

##### Note:
you need to give the permissions to the script so that it can write files and directories to the /usr/bin directory.

---
## Features

hmDB supports:

- Two datatypes for tables data:
    - **str**: (string) which accepts any characters and/or numbers.
    - **int**: (integer) which accepts only numbers.

- primary key constraint using the keyword **pk** , only one primary key is allowed per table.
- Validation of the databases and tables names, it can only start with a character and can't have special characters or spaces.
- database queries such as : create, drop , show databases, and more.
- table queries such as : select, update, insert, delete, describe, and more.

- syntax is inspired from mySQL DBMS syntax with minimum changes, so that it is easier to use.

- All keywords in hmDB are case insensitive, meaning that pk = PK this is also true for all queries (select or SELECT).


for more information about the available queries as well as its syntax please refer to the [help](https://github.com/hossamkhalil01/hmDB/blob/main/hmDBdir/man/help) file inside the [hmDBdir/man](https://github.com/hossamkhalil01/hmDB/blob/main/hmDBdir/man/) directory

or just type *help* inside the interactive mode.

##### Note:
the (*) character in mySQL meaning (all) is swapped to the **all** keyword.


---
## How to Use

Once the installation is done you are ready to use hmDB.
hmDB has two modes of operations one command mode and interactive mode.

#### One Command Mode

In one command mode you can execute one query at a time by passing it as a parameter for the hmDB script.

First run the connect command from anywhere in your machine through the terminal

- run the command *connect* to the establish connection:

```bash
sudo hmDB connect
```

- then run any query as follows:

```bash
sudo hmDB show databases
```

- you can keep running any number of commands you like after you finish use the *disconnect* command to close the connection using the (disconnect) command

```bash
sudo hmDB disconnect
```

#### Interactive Mode

Once you enter the interactive mode just enter the query without the need to type hmDB at the beginning of each query.

you can enter the program in interactive mode using the *-it* flag while running the *connect*.

```bash
sudo hmDB connect -it
```

running this commad will result in entring you in interactive mode as follows


![interactive-mode](https://github.com/hossamkhalil01/hmDB/images/interactive-mode.JPG)

in interactive mode the program will wait for you to enter your query and output the result and wait for another.

To exit the program and disconnect in this mode enter the *exit* command.


## Dependencies

- [bash shell](https://www.gnu.org/software/bash/)
- Linux based operating system.






## Limitations

- A potential shortcoming could appear when the tables (files) are modified externally either by another program or manually.

- hmDB cannot handle the " " as a represntation for the string rather it considers the input as string unless otherwise is specified by the table's datatype.


## Possible Improvements

- Implementation for more functionalities when it comes to the operators rather the the *=* operator only.

- Enhancing the insertion functionality, where you can specify which columns to insert values into rather than going through them in order.

##### Note:

hmDB considers only the entered columns in order and any other unspecified columns are assigned *NULL* values


## Motivation

hmDB was built to experience shell scripting as well as understanding how to use bash commands to convert text files into a file system representing a database utilizing tools such as awk and sed.

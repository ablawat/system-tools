#!/usr/bin/env sh

# get effective user identifier
USER_ID=$(id -u)

# when user is not root
if [ $USER_ID -ne 0 ]
then
    # elevate user privileges into root
    echo 'Switching into root...'
    exec sudo "$0" "$@"
fi

# when one argument is passed
if [ $# -ne 1 ]
then
    # report error and terminate
    echo "[error] Wrong number of arguments."
    exit 1
fi

# when argument is empty
if [ -z "$1" ]
then
    # report error and terminate
    echo "[error] Package list file name is not specified."
    exit 1
fi

# set package list file name
PACKAGE_LIST_FILE_NAME=$1

# when package list file is not existing regular file
if [ ! -f "$PACKAGE_LIST_FILE_NAME" ]
then
    # report error and terminate
    echo "[error] Package list file '$PACKAGE_LIST_FILE_NAME' is not found."
    exit 1
fi

# create empty package list
SYSTEM_PACKAGE_LIST=''

# read every line in file
while read -r line
do
    # when line is not empty
    if [ "$line" ]
    then
        # get first character of the line
        FIRST_CHAR=$(printf %c "$line")

        # when line is not a comment
        if [ $FIRST_CHAR != '#' ]
        then
            # add package to package list
            SYSTEM_PACKAGE_LIST=$SYSTEM_PACKAGE_LIST' '$line
        fi
    fi
done < $PACKAGE_LIST_FILE_NAME

# get every package from package list
for package in $SYSTEM_PACKAGE_LIST
do
    # install package on system
    apt install --assume-yes $package

    # when installation is successful
    if [ $? -eq 0 ]
    then
        # 
        echo "Package '$package' was successfully installed."
    else
        # no action is needed
        echo "[error] Package '$package' could not be installed."
    fi
done

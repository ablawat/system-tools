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

# import external script
. ./package-list.sh

# update system package list
apt update

# when update has failed
if [ $? -ne 0 ]
then
    # report error and terminate
    echo "[error] System package list could not be updated."
    exit 1
fi

# set package list files directory
PACKAGE_LIST_DIR=packages

# find all package list files
PACKAGE_LIST_FILE_NAMES=$(ls $PACKAGE_LIST_DIR | grep '.list$')

# when no files were found
if [ -z "$PACKAGE_LIST_FILE_NAMES" ]
then
    # report error and terminate
    echo "[error] No package list files were found in '$PACKAGE_LIST_DIR'."
    exit 1
fi

# go through every file from list files
for file in $PACKAGE_LIST_FILE_NAMES
do
    # when package list file is not existing regular file
    if [ ! -f $PACKAGE_LIST_DIR/$file ]
    then
        # report error and terminate
        echo "[error] Package list file '$file' is not found."
        return 1
    fi

    # install all packages from file
    package_list_install $PACKAGE_LIST_DIR/$file

    # when installation has failed
    if [ $? -ne 0 ]
    then
        # report error
        echo "[error] Not all packages were installed."

        # go through every not installed package
        for package in $PACKAGE_ERROR_LIST
        do
            # print package name
            echo -n "'$package' "
        done

        # print new line
        echo

        # terminate with error
        exit 1
    fi
done

# report success
echo "All packages were successfully installed."

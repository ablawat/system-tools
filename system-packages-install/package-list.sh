#---------------------
package_list_install()
{
    # set package list file name
    PACKAGE_LIST_FILE_NAME=$1

    # create package list
    PACKAGE_LIST=''

    # read every line from file
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
                PACKAGE_LIST=$PACKAGE_LIST' '$line
            fi
        fi
    done < "$PACKAGE_LIST_FILE_NAME"

    # create package error list
    PACKAGE_ERROR_LIST=''

    # go through every package from package list
    for package in $PACKAGE_LIST
    do
        # install package on system
        apt install --assume-yes $package

        # when installation is successful
        if [ $? -eq 0 ]
        then
            # report success
            echo "Package '$package' was successfully installed."

        # when installation has failed
        else
            # add package to error list
            PACKAGE_ERROR_LIST=$PACKAGE_ERROR_LIST' '$package

            # report error
            echo "[error] Package '$package' could not be installed."
        fi
    done

    # when any of packages has failed to install
    if [ -n "$PACKAGE_ERROR_LIST" ]
    then
        # set return value to failure
        RET_VAL=1
    else
        # set return value to success
        RET_VAL=0
    fi

    return $RET_VAL
}

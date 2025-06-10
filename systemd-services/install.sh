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
. ./service-list.sh

# set script directory
INSTALL_SCRIPT_DIR=/usr/local/bin

# set service directory
INSTALL_CFG_DIR=/etc/systemd/system

# get list of services to install
SERVICE_LIST=$(service_list services.list)

# go to services directory
cd services

# go through every service from service list
for service in $SERVICE_LIST
do
    # indicate start of installation
    echo "Installing '$service' service..."

    # go to service directory
    cd $service

    # when configuration script does not exist
    if [ ! -f configure.sh ]
    then
        # report error and terminate
        echo "[error] Configuration file '$service/configure.sh' is not found."
        exit 1
    fi

    # configure service
    ./configure.sh

    # when configure has failed
    if [ $? -ne 0 ]
    then
        # report error and terminate
        echo "[error] Service '$service' could not be configured."
        exit 1
    fi

    # when script directory does exists
    if [ -d script ]
    then
        # find all script files
        SCRIPT_FILE_NAMES=$(ls script | grep '.sh$')

        # when files are found
        if [ -n "$SCRIPT_FILE_NAMES" ]
        then
            # go to script directory
            cd script

            # copy script files into installation script directory
            cp $SCRIPT_FILE_NAMES $INSTALL_SCRIPT_DIR

            # when copy has failed
            if [ $? -ne 0 ]
            then
                # report error and terminate
                echo "[error] Script files could not be installed in '$INSTALL_SCRIPT_DIR'."
                exit 1
            fi

            # go back to service directory
            cd ../
        fi
    fi

    # when source directory does not exists
    if [ ! -d source ]
    then
        # report error and terminate
        echo "[error] Service directory '$service/source' is not found."
        exit 1
    fi

    # find service file
    SERVICE_FILE_NAME=$(ls source | grep -E '.service$|.mount$')

    # when no files were found
    if [ -z "$SERVICE_FILE_NAME" ]
    then
        # report error and terminate
        echo "[error] No source files were found in '$service/source'."
        exit 1
    fi

    # count service files
    SERVICE_FILE_NUMBER=$(echo "$SERVICE_FILE_NAME" | wc -w)

    # when multiple files were found
    if [ $SERVICE_FILE_NUMBER -ne 1 ]
    then
        # report error and terminate
        echo "[error] More than one service file is found."
        exit 1
    fi

    # copy service files into system service directory
    cp source/$SERVICE_FILE_NAME $INSTALL_CFG_DIR

    # when copy has failed
    if [ $? -ne 0 ]
    then
        # report error and terminate
        echo "[error] Service files could not be installed in '$INSTALL_CFG_DIR'."
        exit 1
    fi

    # [TBD] verify service

    # check service enable status
    RESULT=$(systemctl is-enabled $SERVICE_FILE_NAME)

    # when it is not enabled
    if [ $? -ne 0 ]
    then
        # when it has to be enabled
        if [ "$RESULT" = 'disabled' ]
        then
            # enable service
            systemctl enable $SERVICE_FILE_NAME

            # when enabling has failed
            if [ $? -ne 0 ]
            then
                # report error and terminate
                echo "[error] Service '$service' could not be enabled."
                exit 1
            else
                # report success
                echo "Enabling '$service' service."
            fi
        fi
    fi

    # go out of service directory
    cd ../

    # report success
    echo "Service '$service' is successfully installed."
done

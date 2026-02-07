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

# set installation directory
INSTALL_DIR=/usr/local/bin

# set script name
SCRIPT_NAME=avrasm

# set script files
SCRIPT_FILE_NAMES=avrasm.sh

# copy script files into installation directory
cp $SCRIPT_FILE_NAMES $INSTALL_DIR

# when copy has failed
if [ $? -ne 0 ]
then
    # report error and terminate
    echo "[error] Script could not be installed in '$INSTALL_DIR'."
    exit 1
fi

# when script is not installed
if ! [ -h $INSTALL_DIR/$SCRIPT_NAME ]
then
    # install script
    ln -s $INSTALL_DIR/$SCRIPT_NAME.sh $INSTALL_DIR/$SCRIPT_NAME

    # when installation has failed
    if [ $? -ne 0 ]
    then
        # report error and terminate
        echo "[error] Command '$SCRIPT_NAME' could not be installed in '$INSTALL_DIR'."
        exit 1
    fi
fi

# when directory is not included in PATH
if ! echo $PATH | grep -q "$INSTALL_DIR"
then
    # report warning
    echo "[warning] Directory '$INSTALL_DIR' is not in PATH."
fi

# when script command is not found
if ! command -v $SCRIPT_NAME > /dev/null
then
    # report error and terminate
    echo "[error] Command '$SCRIPT_NAME' is not found."
    exit 1
fi

# report success
echo "Command '$SCRIPT_NAME' is successfully installed."

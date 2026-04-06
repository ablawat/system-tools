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

# set executable installation directory
INSTALL_EXE_DIR=/usr/local/bin

# set configuration installation directory
INSTALL_CFG_DIR=/usr/local/etc

# set script name
SCRIPT_NAME=build-gen

# set script files
SCRIPT_EXE_FILE_NAMES=build-gen.py
SCRIPT_CFG_FILE_NAMES=build-gen.template

# copy script files into installation executable directory
cp $SCRIPT_EXE_FILE_NAMES $INSTALL_EXE_DIR

# when copy has failed
if [ $? -ne 0 ]
then
    # report error and terminate
    echo "[error] Script could not be installed in '$INSTALL_EXE_DIR'."
    exit 1
fi

# create script configuration directory
mkdir -p $INSTALL_CFG_DIR/$SCRIPT_NAME

# when creation has failed
if [ $? -ne 0 ]
then
    # report error and terminate
    echo "[error] Configuration could not be installed in '$INSTALL_CFG_DIR'."
    exit 1
fi

# copy script files into installation configuration directory
cp $SCRIPT_CFG_FILE_NAMES $INSTALL_CFG_DIR/$SCRIPT_NAME

# when copy has failed
if [ $? -ne 0 ]
then
    # report error and terminate
    echo "[error] Configuration could not be installed in '$INSTALL_CFG_DIR'."
    exit 1
fi

# when script is not installed
if ! [ -h $INSTALL_EXE_DIR/$SCRIPT_NAME ]
then
    # install script
    ln -s $INSTALL_EXE_DIR/$SCRIPT_NAME.py $INSTALL_EXE_DIR/$SCRIPT_NAME

    # when installation has failed
    if [ $? -ne 0 ]
    then
        # report error and terminate
        echo "[error] Command '$SCRIPT_NAME' could not be installed in '$INSTALL_EXE_DIR'."
        exit 1
    fi
fi

# when directory is not included in PATH
if ! echo $PATH | grep -q "$INSTALL_EXE_DIR"
then
    # report warning
    echo "[warning] Directory '$INSTALL_EXE_DIR' is not in PATH."
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

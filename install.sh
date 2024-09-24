#!/usr/bin/env sh

# set executable directory
INSTALL_EXE_DIR=/usr/local/bin

# set configuration directory
INSTALL_CFG_DIR=/usr/local/etc

# set script name
SCRIPT_NAME='build-gen'

# set script files
SCRIPT_EXE_FILE_NAMES='build-gen.py'
SCRIPT_CFG_FILE_NAMES='build-gen.template'

# copy script files into installation executable directory
cp $SCRIPT_EXE_FILE_NAMES $INSTALL_EXE_DIR

# when copy has failed
if [ $? -ne 0 ]
then
    # report error and terminate script
    echo "[error] commands are not installed in '$INSTALL_EXE_DIR'"
    exit 1
fi

# create script configuration directory
mkdir -p $INSTALL_CFG_DIR/$SCRIPT_NAME

# when creation has failed
if [ $? -ne 0 ]
then
    # report error and terminate script
    echo "[error] configuration is not installed in '$INSTALL_CFG_DIR'"
    exit 1
fi

# copy script files into installation configuration directory
cp $SCRIPT_CFG_FILE_NAMES $INSTALL_CFG_DIR/$SCRIPT_NAME

# when script is not installed
if ! [ -h $INSTALL_EXE_DIR/$SCRIPT_NAME ]
then
    # install script
    ln -s $INSTALL_EXE_DIR/$SCRIPT_NAME.py $INSTALL_EXE_DIR/$SCRIPT_NAME

    # when installation has failed
    if [ $? -ne 0 ]
    then
        # report error and terminate script
        echo "[error] command '$SCRIPT_NAME' is not installed in '$INSTALL_EXE_DIR'"
        exit 1
    fi
fi

# when directory is not included in PATH
if ! echo $PATH | grep -q "$INSTALL_EXE_DIR"
then
    # report error and terminate script
    echo "[error] '$INSTALL_EXE_DIR' is not in PATH"
    exit 1
fi

# when script command is not found
if ! command -v $SCRIPT_NAME > /dev/null
then
    # report error and terminate script
    echo "[error] commands are not executable through PATH"
    exit 1
fi

echo 'commands are executable through PATH'

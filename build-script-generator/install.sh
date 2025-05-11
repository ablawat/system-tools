#!/usr/bin/env sh

# set executable directory
INSTALL_EXE_DIR=/usr/local/bin

# set configuration directory
INSTALL_CFG_DIR=/usr/local/etc

# set program name
PROGRAM_NAME=build-gen

# set program files
PROGRAM_EXE_FILE_NAMES=build-gen.py
PROGRAM_CFG_FILE_NAMES=build-gen.template

# copy program files into installation executable directory
cp $PROGRAM_EXE_FILE_NAMES $INSTALL_EXE_DIR

# when copy has failed
if [ $? -ne 0 ]
then
    # report error and terminate
    echo "[error] Executable could not be installed in '$INSTALL_EXE_DIR'."
    exit 1
fi

# create program configuration directory
mkdir -p $INSTALL_CFG_DIR/$PROGRAM_NAME

# when creation has failed
if [ $? -ne 0 ]
then
    # report error and terminate
    echo "[error] Configuration could not be installed in '$INSTALL_CFG_DIR'."
    exit 1
fi

# copy program files into installation configuration directory
cp $PROGRAM_CFG_FILE_NAMES $INSTALL_CFG_DIR/$PROGRAM_NAME

# when copy has failed
if [ $? -ne 0 ]
then
    # report error and terminate
    echo "[error] Configuration could not be installed in '$INSTALL_CFG_DIR'."
    exit 1
fi

# when program is not installed
if ! [ -h $INSTALL_EXE_DIR/$PROGRAM_NAME ]
then
    # install program
    ln -s $INSTALL_EXE_DIR/$PROGRAM_NAME.py $INSTALL_EXE_DIR/$PROGRAM_NAME

    # when installation has failed
    if [ $? -ne 0 ]
    then
        # report error and terminate
        echo "[error] Command '$PROGRAM_NAME' could not be installed in '$INSTALL_EXE_DIR'."
        exit 1
    fi
fi

# when directory is not included in PATH
if ! echo $PATH | grep -q "$INSTALL_EXE_DIR"
then
    # report warning
    echo "[warning] Directory '$INSTALL_EXE_DIR' is not in PATH."
fi

# when program command is not found
if ! command -v $PROGRAM_NAME > /dev/null
then
    # report error and terminate
    echo "[error] Command '$PROGRAM_NAME' is not executable through PATH."
    exit 1
fi

# report success
echo "Command '$PROGRAM_NAME' is successfully installed."

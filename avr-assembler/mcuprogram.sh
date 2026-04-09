#!/usr/bin/env sh

# set build directory
BUILD_DIR=build

# find intel hexadecimal object files
HEX_FILE_NAME=$(ls $BUILD_DIR | grep -E '.hex$')

# when no files were found
if [ -z "$HEX_FILE_NAME" ]
then
    # report error and terminate
    echo "[error] No binary files were found in '$BUILD_DIR'."
    exit 1
fi

# count found files
HEX_FILE_NUMBER=$(echo "$HEX_FILE_NAME" | wc -w)

# when more than one file is found
if [ $HEX_FILE_NUMBER -ne 1 ]
then
    # report error and terminate
    echo "[error] More than one binary file is found."
    exit 1
fi

# erase and write binary file on ATtiny817
pymcuprog write --device attiny817 -f $BUILD_DIR/$HEX_FILE_NAME --erase

# when write has failed
if [ $? -ne 0 ]
then
    # report error and terminate
    echo "[error] MCU could not be programmed."
    exit 1
fi

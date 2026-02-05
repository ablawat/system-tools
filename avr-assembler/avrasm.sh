#!/usr/bin/env sh

# set package list file name
PROGRAM_CONFIG_FILE_NAME=program.conf

# define project source file name
SOURCE_NAME=''

# define project target include file name
INCLUDE_NAME=''

# define project peripheral basic software directory name
PERIPHERAL_NAME=''

# define project configuration parameters
OPTIONS_CONFIG='SOURCE_NAME:source-name
                INCLUDE_NAME:include-name
                PERIPHERAL_NAME:peripheral-dir-name'

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
            # go through every option
            for config in $OPTIONS_CONFIG
            do
                # get option name
                NAME=$(echo $config | cut -d ':' -f 2)

                # check for defined option
                echo "$line" | grep -q $NAME

                # when option is defined
                if [ $? -eq 0 ]
                then
                    # get option variable
                    VARIABLE=$(echo $config | cut -d ':' -f 1)

                    # get option value
                    VALUE=$(echo "$line" | sed 's/^[^ ]* *= *//')

                    # set option new vale
                    eval $VARIABLE="'$VALUE'"
                fi
            done
        fi
    fi
done < "$PROGRAM_CONFIG_FILE_NAME"

# when AVR_INC_PATH is not defined
if [ -z ${AVR_INC_PATH+x} ]
then
    # report error and terminate
    echo "[error] 'AVR_INC_PATH'"
    exit 1
fi

# when AVR_BIN_PATH is not defined
if [ -z ${AVR_BIN_PATH+x} ]
then
    # report error and terminate
    echo "[error] 'AVR_BIN_PATH'"
    exit 1
fi

# define assembler executable
AVRASM=avrasm2.exe

# set output directory name
BUILD_DIR_NAME=build

# get file base name
SOURCE_BASE=${SOURCE_NAME%.*}

# get project root directory path
PROGRAM_DIR_PATH=$(pwd)

# define include directories
INCLUDES="-I $AVR_INC_PATH -I $PROGRAM_DIR_PATH/$PERIPHERAL_NAME -i $INCLUDE_NAME"

# define build options
OPTIONS='-fI -W+ie'
#OPTIONS='-fI -W+ie -vl'

# set output file names
SET_OUTPUT_HEX="-o $SOURCE_BASE.hex"
SET_OUTPUT_MAP="-m $SOURCE_BASE.map"
SET_OUTPUT_LSS="-l $SOURCE_BASE.lss"

# define output files
OUTPUTS="$SET_OUTPUT_HEX $SET_OUTPUT_MAP $SET_OUTPUT_LSS"

# create build directory
mkdir -p $BUILD_DIR_NAME

# go to build directory
cd $BUILD_DIR_NAME

# build project binary
wine $AVR_BIN_PATH/$AVRASM $INCLUDES $OPTIONS $OUTPUTS ../$SOURCE_NAME

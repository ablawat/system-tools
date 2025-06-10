#!/usr/bin/env sh

# set user cache directory
USER_CACHE_DIR=/usr/cache

# create user cache directory
mkdir $USER_CACHE_DIR

# when creation has failed
if [ $? -ne 0 ]
then
    # report error and terminate
    echo "[error] User cache could not be created in '$USER_CACHE_DIR'."
    exit 1
fi

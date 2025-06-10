#!/usr/bin/env sh

# disable frequency boosting 
echo 0 | tee /sys/devices/system/cpu/cpufreq/boost

# when operation has failed
if [ $? -ne 0 ]
then
    # report error and terminate
    echo "[error] CPU frequency boosting could not be disabled."
    exit 1
fi

# set frequency scaling governor at the minimum
echo powersave | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null

# when frequency set has failed
if [ $? -ne 0 ]
then
    # report error and terminate
    echo "[error] CPU frequency scaling governor could not be changed."
    exit 1
fi

echo "CPU frequency scaling governor is set to 'powersave'."

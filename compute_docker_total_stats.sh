#!/bin/bash

#free -h
#echo '\n'

# This script is used to complete the output of the docker stats command.
# The docker stats command does not compute the total amount of resources (RAM or CPU)

# Get the total amount of RAM, assumes there are at least 1024*1024 KiB, therefore > 1 GiB
#HOST_MEM_TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2/1024/1024}')
DOCKER_MEM_TOTAL=$(docker info | grep Memory | awk '{print $3}' | grep -o '[0-9]*\.[0-9]*')

# Get the output of the docker stat command. Will be displayed at the end
# Without modifying the special variable IFS the ouput of the docker stats command won't have
# the new lines thus resulting in a failure when using awk to process each line
IFS=;
DOCKER_STATS_CMD=`docker stats --no-stream --format "table {{.MemPerc}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.Name}}"`

# Memory size comuputed as percentage.
# This over estimate ram usage
SUM_RAM=`echo $DOCKER_STATS_CMD | tail -n +2 | sed "s/%//g" | awk '{s+=$1} END {print s}'`
SUM_RAM_QUANTITY=`LC_NUMERIC=C printf %.2f $(echo "$SUM_RAM*$DOCKER_MEM_TOTAL*0.01" | bc)`
SUM_CPU=`echo $DOCKER_STATS_CMD | tail -n +2 | sed "s/%//g" | awk '{s+=$2} END {print s}'`

SUM_MEM=`echo $DOCKER_STATS_CMD | awk '{print $3}' | sed 's/GiB/ * 1024/;s/MiB//;s/KiB/ \/ 1024/' | bc -l | awk '{s+=$1} END {print s}'`
#echo "Memory: $SUM_MEM (MiB)"
SUM_MEM_GiB=`LC_NUMERIC=C printf %.2f $(echo "$SUM_MEM/1024" | bc)`
#echo "Memory: $SUM_MEM_GiB (GiB)"

## Output the result
#echo $DOCKER_STATS_CMD
#echo -e "${SUM_RAM}%\t\t\t${SUM_CPU}%\t\t${SUM_RAM_QUANTITY}GiB / ${DOCKER_MEM_TOTAL}GiB\tTOTAL"

echo "$SUM_CPU|$SUM_MEM"

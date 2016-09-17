#!/bin/bash
# ARGS: $1=scaleNumber $2=username
set -e

echo "Changing to user folder ..."
cd /home/$2/
wait 

# Adjust based on the build of H2O you want to download.
version=1.6
SparklingBranch=rel-${version}

echo "Fetching latest build number for branch ${SparklingBranch}..."
curl --silent -o latest https://h2o-release.s3.amazonaws.com/sparkling-water/${SparklingBranch}/latest
h2oBuild=`cat latest`
wait

echo "Downloading Sparkling Water version ${version}.${h2oBuild} ..."
wget http://h2o-release.s3.amazonaws.com/sparkling-water/${SparklingBranch}/${h2oBuild]/sparkling-water-${version}.${h2oBuild}.zip &
wait

echo "Unzipping sparkling-water-${version}.${h2oBuild}.zip ..."
unzip -o sparkling-water-${version}.${h2oBuild}.zip 1> /dev/null &
wait

echo "Creating SPARKLING_HOME env ..."
export SPARKLING_HOME="/home/$2/sparkling-water-${version}.${h2oBuild}"
export MASTER="yarn-client"
wait


echo "Running sparkling-water-${version}.${h2oBuild}"
# Use 90% of RAM for H2O.
memTotalKb=`cat /proc/meminfo | grep MemTotal | sed 's/MemTotal:[ \t]*//' | sed 's/ kB//'`
memTotalMb=$[ $memTotalKb / 1024 ]
memTotalGB=$[ $memTotalMb / 1024 ]
tmp=$[ $memTotalGB * 90 ]
xmxGb=$[ $tmp / 100 ]
echo "GB memory = ${xmxGb}""

$SPARKLING_HOME/bin/sparkling-shell --num-executors $1 --executor-memory $xmxGb --driver-memory $xmxGb --master yarn-client &
$SPARKLING_HOME/bin/pysparkling --num-executors $1 --executor-memory $xmxGb --driver-memory $xmxGb --master yarn-client &

echo Success.

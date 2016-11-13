#!/bin/bash
# ARGS: $1=scaleNumber $2=username
set -e

echo "Changing to user folder ..."
cd /home/$2/
wait 

#Libraries needed on the worker roles in order to get pysparkling working
/usr/bin/anaconda/bin/pip install -U requests
/usr/bin/anaconda/bin/pip install -U tabulate
/usr/bin/anaconda/bin/pip install -U future
/usr/bin/anaconda/bin/pip install -U six

#Scikit Learn on the nodes
/usr/bin/anaconda/bin/pip install -U scikit-learn

# Adjust based on the build of H2O you want to download.
version=1.6
SparklingBranch=rel-${version}

echo "Fetching latest build number for branch ${SparklingBranch}..."
curl --silent -o latest https://h2o-release.s3.amazonaws.com/sparkling-water/${SparklingBranch}/latest
h2oBuild=`cat latest`
wait

echo "Downloading Sparkling Water version ${version}.${h2oBuild} ..."
wget http://h2o-release.s3.amazonaws.com/sparkling-water/${SparklingBranch}/${h2oBuild}/sparkling-water-${version}.${h2oBuild}.zip &
wait

echo "Unzipping sparkling-water-${version}.${h2oBuild}.zip ..."
unzip -o sparkling-water-${version}.${h2oBuild}.zip 1> /dev/null &
wait

echo "Creating SPARKLING_HOME env ..."
export SPARKLING_HOME="/home/$2/sparkling-water-${version}.${h2oBuild}"
export MASTER="yarn-client"
wait

echo "Copying Sparkling folder to default storage account ... "
hdfs dfs -copyFromLocal -f "/home/$2/sparkling-water-${version}.${h2oBuild}/" "/H2O-Sparkling-Water"
wait

echo "Copying Notebook Examples to default Storage account Jupyter home folder ... "
curl --silent -o 4_sentiment_sparkling.ipynb  "https://raw.githubusercontent.com/pablomarin/H2O-SparklingWater-azure-templates/master/Notebooks/4_sentiment_sparkling.ipynb"
curl --silent -o ChicagoCrimeDemo.ipynb  "https://raw.githubusercontent.com/pablomarin/H2O-SparklingWater-azure-templates/master/Notebooks/ChicagoCrimeDemo.ipynb"
hfds dfs -copyFromLocal -f "./*ipynb" "/HdiNotebooks/H2O-PySparkling/"
wait


echo "Running sparkling-water-${version}.${h2oBuild}"
# Get the available RAM in GB and Number of cores
memTotalKb=`cat /proc/meminfo | grep MemTotal | sed 's/MemTotal:[ \t]*//' | sed 's/ kB//'`
memTotalMb=$[ $memTotalKb / 1024 ]
memTotalGB=$[ $memTotalMb / 1024 ]
usable_mem=$[ $memTotalGB ]
echo "Usable RAM = ${memTotalGB}"

usable_cores=`grep '^core id' /proc/cpuinfo |sort -u|wc -l`
usable_cores=$[ $usable_cores - 1]
echo "Usables Cores = ${usable_cores}"

factor=3
num_executors=$[ ($1 * $factor) - 1]
executor_cores=$[ $usable_cores / $factor]
executor_cores=${executor_cores%.*}
executor_memory=$(($usable_mem / $factor))
executor_memory=${executor_memory%.*}

echo "num_executors = ${num_executors}"
echo "executor_cores = ${executor_cores}"
echo "executor_memory = ${executor_memory}"

#$SPARKLING_HOME/bin/sparkling-shell --num-executors $num_executors --executor-cores ${executor_cores} --executor-memory ${executor_memory}g --driver-memory ${usable_mem}g --master yarn-client &
#$SPARKLING_HOME/bin/pysparkling --num-executors $num_executors --executor-cores ${executor_cores} --executor-memory ${executor_memory}g --driver-memory ${usable_mem}g --master yarn-client &

echo Success.

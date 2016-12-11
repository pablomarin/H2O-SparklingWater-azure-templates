#!/bin/bash
# ARGS: $1=username $2=SparkVersion
set -e

echo "Changing to user folder ..."
cd /home/$1/
wait 

#Libraries needed on the worker roles in order to get pysparkling working
/usr/bin/anaconda/bin/pip install -U requests
/usr/bin/anaconda/bin/pip install -U tabulate
/usr/bin/anaconda/bin/pip install -U future
/usr/bin/anaconda/bin/pip install -U six

#Scikit Learn on the nodes
/usr/bin/anaconda/bin/pip install -U scikit-learn

# Adjust based on the build of H2O you want to download.
version=$2
SparklingBranch=rel-${version}

echo "Fetching latest build number for branch ${SparklingBranch}..."
curl --silent -o latest https://h2o-release.s3.amazonaws.com/sparkling-water/${SparklingBranch}/latest
h2oBuild=`cat latest`

echo "Downloading Sparkling Water version ${version}.${h2oBuild} ..."
wget http://h2o-release.s3.amazonaws.com/sparkling-water/${SparklingBranch}/${h2oBuild}/sparkling-water-${version}.${h2oBuild}.zip &
wait

echo "Unzipping sparkling-water-${version}.${h2oBuild}.zip ..."
unzip -o sparkling-water-${version}.${h2oBuild}.zip 1> /dev/null &
wait

echo "Creating SPARKLING_HOME env ..."
export SPARKLING_HOME="/home/$1/sparkling-water-${version}.${h2oBuild}"
export MASTER="yarn-client"

echo "Copying Sparkling folder to default storage account ... "
hdfs dfs -mkdir -p "/H2O-Sparkling-Water"
hdfs dfs -put -f /home/$1/sparkling-water-${version}.${h2oBuild}/* /H2O-Sparkling-Water/

echo "Copying Notebook Examples to default Storage account Jupyter home folder ... "
curl --silent -o 4_sentiment_sparkling.ipynb  "https://raw.githubusercontent.com/pablomarin/H2O-SparklingWater-azure-templates/master/Notebooks/4_sentiment_sparkling.ipynb"
curl --silent -o ChicagoCrimeDemo.ipynb  "https://raw.githubusercontent.com/pablomarin/H2O-SparklingWater-azure-templates/master/Notebooks/ChicagoCrimeDemo.ipynb"
hdfs dfs -mkdir -p "/HdiNotebooks/H2O-PySparkling-Examples"
hdfs dfs -put -f *.ipynb /HdiNotebooks/H2O-PySparkling-Examples/

echo "Success"

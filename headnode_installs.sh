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
mkdir "H2O-PySparkling-Examples"
mv "./*.ipynb" "./H2O-PySparkling-Examples/"
hdfs dfs -copyFromLocal -f "./H2O-PySparkling-Examples/" "/HdiNotebooks/H2O-PySparkling-Examples"
wait

echo Success.

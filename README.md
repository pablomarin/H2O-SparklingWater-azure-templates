# SparklingWater-azure-template

The goal of this repo is to provide an easy (click-and-go) way to deploy H2O Sparkling Water clusters on Microsoft Azure.

There are two kind of templates offered on this repo.

1. Simple: <a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fpablomarin%2FSparklingWater-azure-template%2Fmaster%2Fazuredeploy-simple.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
	- HDInsight 3.5
	- Spark 1.6.2
	- Latest version of H2O Sparkling water 
	- VNet with NSG (Network Security Group)
2. Advanced: <a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fpablomarin%2FSparklingWater-azure-template%2Fmaster%2Fazuredeploy-advanced.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
	- HDInsight 3.5
	- Spark 1.6.2
	- Latest version of H2O Sparkling water 
	- VNet with NSG (Network Security Group)
	- Additional data source (Linked Storage Account)
	- External Hive/Oozie Metastore (SQL Database)
	
It takes about 20 minutes to create the cluster.


## Azure HDInsight Architecture

![HDI arch](https://acom.azurecomcdn.net/80C57D/cdn/mediahandler/docarticles/dpsmedia-prod/azure.microsoft.com/en-us/documentation/articles/hdinsight-hadoop-use-blob-storage/20160913101040/hdi.wasb.arch.png)

Hadoop supports a notion of the default file system. The default file system implies a default scheme and authority. It can also be used to resolve relative paths. During the HDInsight creation process, an Azure Storage account and a specific Azure Blob storage container from that account is designated as the default file system.

For the files on the default file system, you can use a relative path or an absolute path. For example, the *hadoop-mapreduce-examples.jar* file that comes with HDInsight clusters can be referred to by using one of the following:

	wasbs://mycontainer@myaccount.blob.core.windows.net/example/jars/hadoop-mapreduce-examples.jar
	wasbs:///example/jars/hadoop-mapreduce-examples.jar
	/example/jars/hadoop-mapreduce-examples.jar

In addition to this storage account, you can add additional storage accounts (<b>Advanced Template)</b> from the same Azure subscription or different Azure subscriptions during the creation process or after a cluster has been created. Note that the additional storage account must be in the same region thatn the HDI cluster. <b>Normally this is where your big data resides</b>. The syntax is:

	wasb[s]://<containername>@<accountname>.blob.core.windows.net/<path>
	
HDInsight provides  also access to the distributed file system that is locally attached to the compute nodes (disks on the cluster nodes). You can use this as a local cache. Remember that this file system is gone once you delete the cluster. This file system can be accessed by using the fully qualified URI, for example:

	hdfs://<namenodehost>/<path>
	
Most HDFS commands (for example, <b>ls</b>, <b>copyFromLocal</b> and <b>mkdir</b>) still work as expected. Only the commands that are specific to the native HDFS implementation (which is referred to as DFS), such as <b>fschk</b> and <b>dfsadmin</b>, will show different behavior in Azure Blob storage.

Only the data on the linked storage account and the external hive meta-store will persist after the cluster is deleted. <b>MAKE SURE YOU DO NOT STORE YOUR IMPORTANT DATA ON THE DEFAULT STORAGE ACCOUNT CREATED BY THE CLUSTER</b>.


## H2O Sparkling Water Architecture

![Sparkling architecture](http://www.ibmbigdatahub.com/sites/default/files/quality_of_life_fig_1.jpg)

Both templates will automatically download the latest version of Sparkling Water compatible with Spark 1.6.2.
It will also copy the sparkling water folder on the default storage under /HDINotebooks/Sparkling/.

H2O can be installed as a standalone cluster, on top of YARN, and on top of spark on top of YARN.
Both templates introduced in this repo install H2O on top of Spark on top of YARN => Sparkling Water on YARN.

Note that all spark applications deployed using a Jupyter Notebook will have "yarn-cluster" deploy-mode. This means that the sparkling water driver can be allocated on any node of the cluster, not necessarily on the head node.



## Create Jupyter notebook with PySpark kernel 

HDInsight Spark clusters provide two kernels that you can use with the Jupyter notebook. These are:

* **PySpark** (for applications written in Python)
* **Spark** (for applications written in Scala)

Couple of key benefits of using the PySpark kernel are:

* You do not need to set the contexts for Spark and Hive. These are automatically set for you.
* You can use cell magics, such as `%%sql`, to directly run your SQL or Hive queries, without any preceding code snippets.
* The output for the SQL or Hive queries is automatically visualized.


1. From the [Azure Portal](https://portal.azure.com/), from the startboard, click the tile for your Spark cluster (if you pinned it to the startboard). You can also navigate to your cluster under **Browse All** > **HDInsight Clusters**.   

2. From the Spark cluster blade, click **Quick Links**, and then from the **Cluster Dashboard** blade, click **Jupyter Notebook**. If prompted, enter the admin credentials for the cluster.

	> you may also reach the Jupyter Notebook for your cluster by opening the following URL in your browser. Replace __CLUSTERNAME__ with the name of your cluster:
	>
	> `https://CLUSTERNAME.azurehdinsight.net/jupyter`


## Where are the notebooks stored?

Jupyter notebooks are saved to the storage account associated with the cluster under the **/HdiNotebooks** folder.  Notebooks, text files, and folders that you create from within Jupyter will be accessible from WASB.  For example, if you use Jupyter to create a folder **myfolder** and a notebook **myfolder/mynotebook.ipynb**, you can access that notebook at `wasbs:///HdiNotebooks/myfolder/mynotebook.ipynb`.  The reverse is also true, that is, if you upload a notebook directly to your storage account at `/HdiNotebooks/mynotebook1.ipynb`, the notebook will be visible from Jupyter as well.  Notebooks will remain in the storage account even after the cluster is deleted.

The way notebooks are saved to the storage account is compatible with HDFS. So, if you SSH into the cluster you can use file management commands like the following:

	hdfs dfs -ls /HdiNotebooks             				  # List everything at the root directory – everything in this directory is visible to Jupyter from the home page
	hdfs dfs –copyToLocal /HdiNotebooks    				# Download the contents of the HdiNotebooks folder
	hdfs dfs –copyFromLocal example.ipynb /HdiNotebooks   # Upload a notebook example.ipynb to the root folder so it’s visible from Jupyter


In case there are issues accessing the storage account for the cluster, the notebooks are also saved on the headnode `/var/lib/jupyter`.



## Delete the cluster

To delete the Sparkling Water Cluster, go to the portal and delete the Resource Group.



## Data source

The original Hadoop distributed file system (HDFS) uses many local disks on the cluster. HDInsight uses Azure Blob storage for data storage. Azure Blob storage is a robust, general-purpose storage solution that integrates seamlessly with HDInsight. Through an HDFS interface, the full set of components in HDInsight can operate directly on structured or unstructured data in Blob storage. Storing data in Blob storage helps you safely delete the HDInsight clusters that are used for computation without losing user data.

During configuration, you must specify an Azure storage account and an Azure Blob storage container on the Azure storage account. The Blob storage container is used as the default storage location by the cluster. Optionally, you can specify additional Azure Storage accounts (linked storage) that will be accessible by the cluster. The cluster can also access any Blob storage containers that are configured with full public read access or public read access for blobs only. 

It is not recommended using the default Blob storage container for storing business data. Deleting the default Blob storage container after each use to reduce storage cost is a good practice. Note that the default container contains application and system logs. Make sure to retrieve the logs before deleting the container.


## Use additional storage - Advanced Template

In some cases, you may wish to add additional storage to the cluster. For example, you might have multiple Azure storage accounts for different geographical regions or different services, but you want to analyze them all with HDInsight.


##<a name="next-steps"></a>What components are included as part of a Spark cluster?

![hdi-arch](https://github.com/pablomarin/SparklingWater-azure-template-work-in-progress-/blob/master/images/hdi-arch.png?raw=true)

Spark in HDInsight includes the following components that are available on the clusters by default.

- [Spark Core](https://spark.apache.org/docs/1.5.1/). Includes Spark Core, Spark SQL, Spark streaming APIs, GraphX, and MLlib.
- [Anaconda](http://docs.continuum.io/anaconda/)
- [Livy](https://github.com/cloudera/hue/tree/master/apps/spark/java#welcome-to-livy-the-rest-spark-server)
- [Jupyter Notebook](https://jupyter.org)

Spark in HDInsight also provides an [ODBC driver](http://go.microsoft.com/fwlink/?LinkId=616229) for connectivity to Spark clusters in HDInsight from BI tools such as Microsoft Power BI and Tableau.


## Use Hive/Oozie metastore - Advanced Template

We strongly recommend that you use a custom metastore if you want to retain your Hive tables after you delete your HDInsight cluster. You will be able to attach that metastore to another HDInsight cluster.

The metastore contains Hive and Oozie metadata, such as Hive tables, partitions, schemas, and columns. The metastore helps you to retain your Hive and Oozie metadata, so you don't need to re-create Hive tables or Oozie jobs when you create a new cluster. By default, Hive uses an embedded Azure SQL database to store this information. The embedded database can't preserve the metadata when the cluster is deleted. When you create Hive table in an HDInsight cluster with an Hive metastore configured, those tables will be retained when you recreate the cluster using the same Hive metastore.

> When creating a custom metastore, do not use a database name that contains dashes or hyphens. This can cause the cluster creation process to fail.

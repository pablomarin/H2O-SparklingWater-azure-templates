# SparklingWater-azure-template
ARM Template that creates a HDInsight Spark cluster and installs H2O Sparkling water on it

>This repo uses an ARM template to create a Spark cluster with H2O Sparkling Water installed on it, that uses [Azure Storage Blobs as the cluster storage](hdinsight-hadoop-use-blob-storage.md). You can also create a Spark cluster that uses [Azure Data Lake Store](../data-lake-store/data-lake-store-overview.md) as an additional storage, in addition to Azure Storage Blobs as the default storage. For instructions, see [Create an HDInsight cluster with Data Lake Store](../data-lake-store/data-lake-store-hdinsight-hadoop-use-portal.md).

## Create Sparkling Water cluster

In this section, you create an HDInsight version 3.4 cluster (Spark version 1.6.1) using an Azure ARM template. For information about HDInsight versions and their SLAs, see [HDInsight component versioning](hdinsight-component-versioning.md). For other cluster creation methods, see [Create HDInsight clusters](hdinsight-hadoop-provision-linux-clusters.md).

1. Click the following image to open an ARM template in the Azure Portal.         

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fpablomarin%2FSparklingWater-azure-template%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fpablomarin%2FSparklingWater-azure-template%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>
    
    
2. From the Parameters blade, enter the following:

    - **ClusterName**: Enter a name for the Hadoop cluster that you will create.
    - **Cluster login name and password**: The default login name is admin.
    - **SSH user name and password**.
    
    Please write down these values.  You will need them later in the tutorial.

    > SSH is used to remotely access the HDInsight cluster using a command-line. The user name and password you use here is used when connecting to the cluster through SSH. Also, the SSH user name must be unique, as it creates a user account on all the HDInsight cluster nodes. The following are some of the account names reserved for use by services on the cluster, and cannot be used as the SSH user name:
    >
    > root, hdiuser, storm, hbase, ubuntu, zookeeper, hdfs, yarn, mapred, hbase, hive, oozie, falcon, sqoop, admin, tez, hcat, hdinsight-zookeeper.

	> For more information on using SSH with HDInsight, see one of the following articles:

	> * [Use SSH with Linux-based Hadoop on HDInsight from Linux, Unix, or OS X](hdinsight-hadoop-linux-use-ssh-unix.md)
	> * [Use SSH with Linux-based Hadoop on HDInsight from Windows](hdinsight-hadoop-linux-use-ssh-windows.md)

    
3.Click **OK** to save the parameters.

4.From the **Custom deployment** blade, click **Resource group** dropdown box, and then click **New** to create a new resource group. The resource group is a container that groups the cluster, the dependent storage account and other linked resource.

5.Click **Legal terms**, and then click **Create**.

6.Click **Create**. You will see a new tile titled Submitting deployment for Template deployment. It takes about around 20 minutes to create the cluster and SQL database.

## Run Spark SQL queries using a Jupyter notebook

In this section, you use Jupyter notebook to run Spark SQL queries against the Spark cluster. HDInsight Spark clusters provide two kernels that you can use with the Jupyter notebook. These are:

* **PySpark** (for applications written in Python)
* **Spark** (for applications written in Scala)

In this article, you will use the PySpark kernel. In the article [Kernels available on Jupyter notebooks with Spark HDInsight clusters](hdinsight-apache-spark-jupyter-notebook-kernels.md#why-should-i-use-the-new-kernels) you can read in detail about the benefits of using the PySpark kernel. However, couple of key benefits of using the PySpark kernel are:

* You do not need to set the contexts for Spark and Hive. These are automatically set for you.
* You can use cell magics, such as `%%sql`, to directly run your SQL or Hive queries, without any preceding code snippets.
* The output for the SQL or Hive queries is automatically visualized.

### Tips for Executor memory allocation 
Assume there are 6 nodes available on a cluster with 25 core nodes and 125 GB memory per node. It is natural to try to utilize those resources as much as possible for your Sparkling Water application, before considering requesting more nodes (which might result in longer wait times in the queue and overall longer times to get the result). 

With YARN, a possible approach would be to use --num-executors 6 --executor-cores 24 --executor-memory 124G. Here, we subtracted 1 core and some memory per node to allow for operating system and/or cluster specific daemons to run. However, this approach would be not be optimal, because large number of cores per executor leads to HDFS I/O throughput and thus significantly slow down the application. Allocating a similar number of cores would be possible by increasing the number of executors and decreasing the number of executor-cores and memory.

A recommended approach when using YARN would be to use --num-executors 30 --executor-cores 4 --executor-memory 24G. Which would result in YARN allocating 30 containers with executors, 5 containers per node using up 4 executor cores each. The RAM per container on a node 124/5= 24GB (roughly).

This is the formula:<br>
usable_mem = mem_per_node - 1G<br>
usable_cores = cores_per_node - 1<br>
n = 3 or 5 (make it so the number of cores per executor should be maximum 5)<br>
<br>
num-executors = no_nodes x n - 1<br>
executor-cores = usable_cores / n<br>
executor-memory = usable_mem * 0.97 / n <br>


### Create Jupyter notebook with PySpark kernel 

1. From the [Azure Portal](https://portal.azure.com/), from the startboard, click the tile for your Spark cluster (if you pinned it to the startboard). You can also navigate to your cluster under **Browse All** > **HDInsight Clusters**.   

2. From the Spark cluster blade, click **Quick Links**, and then from the **Cluster Dashboard** blade, click **Jupyter Notebook**. If prompted, enter the admin credentials for the cluster.

	> ou may also reach the Jupyter Notebook for your cluster by opening the following URL in your browser. Replace __CLUSTERNAME__ with the name of your cluster:
	>
	> `https://CLUSTERNAME.azurehdinsight.net/jupyter`

##Delete the cluster

To delete the Sparkling Water Cluster, go to the portal and delete the Resource Group.

### Data source###

The original Hadoop distributed file system (HDFS) uses many local disks on the cluster. HDInsight uses Azure Blob storage for data storage. Azure Blob storage is a robust, general-purpose storage solution that integrates seamlessly with HDInsight. Through an HDFS interface, the full set of components in HDInsight can operate directly on structured or unstructured data in Blob storage. Storing data in Blob storage helps you safely delete the HDInsight clusters that are used for computation without losing user data.

During configuration, you must specify an Azure storage account and an Azure Blob storage container on the Azure storage account. Some creation processes require the Azure storage account and the Blob storage container to be created beforehand. The Blob storage container is used as the default storage location by the cluster. Optionally, you can specify additional Azure Storage accounts (linked storage) that will be accessible by the cluster. The cluster can also access any Blob storage containers that are configured with full public read access or public read access for blobs only.  For more information, see [Manage Access to Azure Storage Resources](../storage/storage-manage-access-to-resources.md).

![HDInsight storage](./media/hdinsight-provision-clusters/HDInsight.storage.png)

> A Blob storage container provides a grouping of a set of blobs as shown in the following image.

![Azure blob storage](./media/hdinsight-provision-clusters/Azure.blob.storage.jpg)

We do not recommended using the default Blob storage container for storing business data. Deleting the default Blob storage container after each use to reduce storage cost is a good practice. Note that the default container contains application and system logs. Make sure to retrieve the logs before deleting the container.

>Sharing one Blob storage container for multiple clusters is not supported.

For more information on using secondary Blob storage, see [Using Azure Blob Storage with HDInsight](hdinsight-hadoop-use-blob-storage.md).

In addition to Azure Blob storage, you can also use [Azure Data Lake Store](../data-lake-store/data-lake-store-overview.md) as a default storage account for HBase cluster in HDInsight and as linked storage for all four HDInsight cluster types. For more information, see [Create an HDInsight cluster with Data Lake Store using Azure Portal](../data-lake-store/data-lake-store-hdinsight-hadoop-use-portal.md).

### Location (Region) ###

The HDInsight cluster and its default storage account must be located at the same Azure location.

![Azure regions](./media/hdinsight-provision-clusters/Azure.regions.png)

For a list of supported regions, click the **Region** drop-down list on [HDInsight pricing](https://go.microsoft.com/fwLink/?LinkID=282635&clcid=0x409).

## Use additional storage

In some cases, you may wish to add additional storage to the cluster. For example, you might have multiple Azure storage accounts for different geographical regions or different services, but you want to analyze them all with HDInsight.

You can add storage accounts when you create an HDInsight cluster or after a cluster has been created.  See [Customize Linux-based HDInsight clusters using Script Action](hdinsight-hadoop-customize-cluster-linux.md).

For more information about secondary Blob storage, see [Using Azure Blob storage with HDInsight](hdinsight-hadoop-use-blob-storage.md). For more information about secondary Data Lake Storage, see [Create HDInsight clusters with Data Lake Store using Azure Portal](../data-lake-store/data-lake-store-hdinsight-hadoop-use-portal.md).

##<a name="next-steps"></a>What components are included as part of a Spark cluster?

Spark in HDInsight includes the following components that are available on the clusters by default.

- [Spark Core](https://spark.apache.org/docs/1.5.1/). Includes Spark Core, Spark SQL, Spark streaming APIs, GraphX, and MLlib.
- [Anaconda](http://docs.continuum.io/anaconda/)
- [Livy](https://github.com/cloudera/hue/tree/master/apps/spark/java#welcome-to-livy-the-rest-spark-server)
- [Jupyter Notebook](https://jupyter.org)

Spark in HDInsight also provides an [ODBC driver](http://go.microsoft.com/fwlink/?LinkId=616229) for connectivity to Spark clusters in HDInsight from BI tools such as Microsoft Power BI and Tableau.

## Where do I start?

Start with creating a Spark cluster on HDInsight Linux. See [QuickStart: create a Spark cluster on HDInsight Linux and run sample applications using Jupyter](hdinsight-apache-spark-jupyter-spark-sql.md). 


## Use Hive/Oozie metastore

We strongly recommend that you use a custom metastore if you want to retain your Hive tables after you delete your HDInsight cluster. You will be able to attach that metastore to another HDInsight cluster.

> HDInsight metastore is not backward compatible. For example, you cannot use a metastore of an HDInsight 3.4 cluster to create an HDInsight 3.3 cluster.

The metastore contains Hive and Oozie metadata, such as Hive tables, partitions, schemas, and columns. The metastore helps you to retain your Hive and Oozie metadata, so you don't need to re-create Hive tables or Oozie jobs when you create a new cluster. By default, Hive uses an embedded Azure SQL database to store this information. The embedded database can't preserve the metadata when the cluster is deleted. When you create Hive table in an HDInsight cluster with an Hive metastore configured, those tables will be retained when you recreate the cluster using the same Hive metastore.

Metastore configuration is not available for HBase cluster types.

> When creating a custom metastore, do not use a database name that contains dashes or hyphens. This can cause the cluster creation process to fail.

### Manage resources

* [Manage resources for the Apache Spark cluster in Azure HDInsight](hdinsight-apache-spark-resource-manager.md)

* [Track and debug jobs running on an Apache Spark cluster in HDInsight](hdinsight-apache-spark-job-debugging.md)


## Use external packages with Jupyter notebooks 

1. From the [Azure Portal](https://portal.azure.com/), from the startboard, click the tile for your Spark cluster (if you pinned it to the startboard). You can also navigate to your cluster under **Browse All** > **HDInsight Clusters**.   

2. From the Spark cluster blade, click **Quick Links**, and then from the **Cluster Dashboard** blade, click **Jupyter Notebook**. If prompted, enter the admin credentials for the cluster.

	> You may also reach the Jupyter Notebook for your cluster by opening the following URL in your browser. Replace __CLUSTERNAME__ with the name of your cluster:
	>
	> `https://CLUSTERNAME.azurehdinsight.net/jupyter`

2. Create a new notebook. Click **New**, and then click **Spark**.

	![Create a new Jupyter notebook](https://raw.githubusercontent.com/Azure/azure-content/master/articles/hdinsight/media/hdinsight-apache-spark-jupyter-notebook-use-external-packages/hdispark.note.jupyter.createnotebook.png "Create a new Jupyter notebook")

3. A new notebook is created and opened with the name Untitled.pynb. Click the notebook name at the top, and enter a friendly name.

	![Provide a name for the notebook](https://raw.githubusercontent.com/Azure/azure-content/master/articles/hdinsight/media/hdinsight-apache-spark-jupyter-notebook-use-external-packages/hdispark.note.jupyter.notebook.name.png "Provide a name for the notebook")

4. You will use the `%%configure` magic to configure the notebook to use an external package. In notebooks that use external packages, make sure you call the `%%configure` magic in the first code cell. This ensures that the kernel is configured to use the package before the session starts.

		%%configure
		{ "packages":["com.databricks:spark-csv_2.10:1.4.0"] }


	>if you forget to configure the kernel in the first cell, you can use the `%%configure` with the `-f` parameter, but that will restart the session and all progress will be lost.

5. In the snippet above, `packages` expects a list of maven coordinates in Maven Central Repository. In this snippet, `com.databricks:spark-csv_2.10:1.4.0` is the maven coordinate for **spark-csv** package. Here's how you construct the coordinates for a package.

	a. Locate the package in the Maven Repository. For this tutorial, we use [spark-csv](http://search.maven.org/#artifactdetails%7Ccom.databricks%7Cspark-csv_2.10%7C1.4.0%7Cjar).
	
	b. From the repository, gather the values for **GroupId**, **ArtifactId**, and **Version**.

	![Use external packages with Jupyter notebook](https://raw.githubusercontent.com/Azure/azure-content/master/articles/hdinsight/media/hdinsight-apache-spark-jupyter-notebook-use-external-packages/use-external-packages-with-jupyter.png "Use external packages with Jupyter notebook")

	c. Concatenate the three values, separated by a colon (**:**).

		com.databricks:spark-csv_2.10:1.4.0

6. Run the code cell with the `%%configure` magic. This will configure the underlying Livy session to use the package you provided. In the subsequent cells in the notebook, you can now use the package, as shown below.

		val df = sqlContext.read.format("com.databricks.spark.csv").
        option("header", "true").
        option("inferSchema", "true").
        load("wasbs:///HdiSamples/HdiSamples/SensorSampleData/hvac/HVAC.csv")

7. You can then run the snippets, like shown below, to view the data from the dataframe you created in the previous step.

		df.show()

		df.select("Time").count()


## <a name="seealso"></a>See also


* [Overview: Apache Spark on Azure HDInsight](hdinsight-apache-spark-overview.md)

This is dashboard for out Hadoop clusters

Here you can see cluster with HDFS + YARN + HBase.
![HDFS + YARN + HBase](/assets/images/screenshot1.png "HDFS + YARN + HBase")


In this screenshot you can see failing a running jobs. This jobs are download from http://$masterurl:8088/ws/v1/cluster/apps
**Failing jobs** show:
  * name
  * datetime when job failed
  * last success complete job with same name

**Running jobs** show:
  * name
  * datetime start
  * owner
  * type (yarn, spark, mr, ...)
![Failing and running jobs](/assets/images/screenshot2.png "Failing")

This use dashing. For more info check out http://shopify.github.com/dashing .

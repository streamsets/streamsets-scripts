# patch.sdc.sh
## Prerequisites

1. Install zip/unzip/realpath utility if it is not available
2. Backup the entire SDC folder to a path outside the original SDC folder.
3. Create a temporary path outside SDC path, Download and copy the analyze and patch script into the temporary path. Make sure the owner of temporary path is same as the owner of SDC home directory.
4. Always run both the script using the owner of the SDC home directory.



## To patch the Log4j jars
Step 1: cd ```<temporary path where the analyze and patch script are downloaded>```<br/>
Step 2: To run the script, use the following command.
sh patch.sdc.sh patch ```<Option1>``` ```<Option2>```<br/>
--Option1 : $SDC_DIST  Directory path <br/>
--Option2 : Flag to remove the JndiLookup.class. <br/>
		    If set to true, old log4j jars will be replaced by log4j 2.17.1 jars and JndiLookup.class will be removed from new log4j jars and databricks-jdbc42-*.jar <br/>
		    If set to false, only old log4j jars will be replaced with new log4j jars.<br/>

eg., sh patch.sdc.sh patch /user/root/sdc_home/ true

Step 3: Validating the output

sh patch.sdc.sh patch /user/root/sdc_home/ true

```
Renaming JAR file /user/root/sdc_home//streamsets-libs/streamsets-datacollector-cdh_6_0-lib/lib/log4j-1.2-api-2.8.2.jar to /user/root/sdc_home//streamsets-libs/streamsets-datacollector-cdh_6_0-lib/lib/log4j-1.2-api-2.8.2.jar.backup
Copying JAR file log4j-1.2-api-2.17.1.jar to /user/root/sdc_home//streamsets-libs/streamsets-datacollector-cdh_6_0-lib/lib
Patching file /user/root/sdc_home//streamsets-libs/streamsets-datacollector-cdh_6_0-lib/lib/log4j-1.2-api-2.17.1.jar
```

sh patch.sdc.sh patch /user/root/sdc_home/ false

```
Renaming JAR file /user/root/sdc_home//streamsets-libs/streamsets-datacollector-cdh_6_0-lib/lib/log4j-1.2-api-2.8.2.jar to /user/root/sdc_home//streamsets-libs/streamsets-datacollector-cdh_6_0-lib/lib/log4j-1.2-api-2.8.2.jar.backup
Copying JAR file log4j-1.2-api-2.17.1.jar to /user/root/sdc_home//streamsets-libs/streamsets-datacollector-cdh_6_0-lib/lib
```

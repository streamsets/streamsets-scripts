#!/bin/sh
#
# Copyright (c) 2021 StreamSets Inc.
#
# This script addresses Log4J vulnerabilities CVE-2021-44228, CVE-2021-45046, CVE-2021-45105 and LOG4J2-3230

downloadArtifacts()
{
  curl -o log4j-1.2-api-2.17.0.jar    https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-1.2-api/2.17.0/log4j-1.2-api-2.17.0.jar
  curl -o log4j-api-2.17.0.jar        https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-api/2.17.0/log4j-api-2.17.0.jar
  curl -o log4j-core-2.17.0.jar       https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-core/2.17.0/log4j-core-2.17.0.jar
  curl -o log4j-web-2.17.0.jar        https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-web/2.17.0/log4j-web-2.17.0.jar
  curl -o log4j-slf4j-impl-2.17.0.jar https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-slf4j-impl/2.17.0/log4j-slf4j-impl-2.17.0.jar
}

searchArtifacts()
{
  rootFolder=$1

  find $rootFolder -type f -name "log4j-1.2-api-2.*.jar"     | while read jarFile; do replaceArtifact $jarFile log4j-1.2-api-2.17.0.jar; done
  find $rootFolder -type f -name "log4j-api-2.*.jar"         | while read jarFile; do replaceArtifact $jarFile log4j-api-2.17.0.jar; done
  find $rootFolder -type f -name "log4j-core-2.*.jar"        | while read jarFile; do replaceArtifact $jarFile log4j-core-2.17.0.jar; done
  find $rootFolder -type f -name "log4j-web-2.*.jar"         | while read jarFile; do replaceArtifact $jarFile log4j-web-2.17.0.jar; done
  find $rootFolder -type f -name "log4j-slf4j-impl-2.*.jar"  | while read jarFile; do replaceArtifact $jarFile log4j-slf4j-impl-2.17.0.jar; done
  if [ "${patchFiles}" = "true" ]; then
    find $rootFolder -type f -name "databricks-jdbc42-*.jar" | while read jarFile; do patchArtifact $jarFile; done
  fi
}

replaceArtifact()
{
  oldJarFile=$1
  newJarFile=$2

  baseFolder=$(dirname "${oldJarFile}")

  echo "Renaming JAR file ${oldJarFile} to ${oldJarFile}.backup"
  mv ${oldJarFile} ${oldJarFile}.backup

  echo "Copying JAR file ${newJarFile} to ${baseFolder}"
  cp ${newJarFile} ${baseFolder}

  if [ "${patchFiles}" = "true" ]; then
    echo "Patching file ${baseFolder}/${newJarFile}"
    zip -d ${baseFolder}/${newJarFile} org/apache/logging/log4j/core/lookup/JndiLookup.class | grep -v "zip warning" | grep -v "Nothing to do"
  fi
}

patchArtifact()
{
  jarFile=$1

  echo "Copying JAR file ${jarFile} to ${jarFile}.backup"
  cp ${jarFile} ${jarFile}.backup

  echo "Patching file ${jarFile}"
  zip -d ${jarFile} com/simba/spark/jdbc42/internal/apache/logging/log4j/core/lookup/JndiLookup.class | grep -v "zip warning" | grep -v "Nothing to do"
}

help()
{
  echo "Usage: $0 { patch folder option | help }"
  echo "   folder: Root Data Collector folder"
  echo "   option { true | false }: Remove JndiLookup.class from vulnerable libraries"

}

currentFolder=`pwd`
option=$1
sdcFolder=$2
patchFiles=$3

case "${option}" in
  'patch')
    if [ "${sdcFolder}" = "" ]; then
      echo "Error: Data Collector folder cannot be empty"
      echo "Patch process aborted"
      help
      exit 1
    fi
    if [ -d ${sdcFolder} ]; then
      echo "Using Data Collectorfolder ${sdcFolder}"
    else
      echo "Error: ${sdcFolder} is not a folder"
      echo "Patch process aborted"
      help
      exit 1
    fi

    if [ "${patchFiles}" = "true" -o "${patchFiles}" = "false" ]; then
      echo "Using patch option ${patchFiles}"
    else
      echo "Error: Patch option must be true or false"
      echo "Patch process aborted"
      help
      exit 1
    fi

    relativePath=`realpath -P --relative-base=${sdcFolder} ${currentFolder}`
    if [ "${relativePath:0:1}" != "/" ]; then
      echo "Error: Current folder cannot be a subfolder of Data Collector folder"
      echo "Patch process aborted"
      help
      exit 1
    fi

    downloadArtifacts
    searchArtifacts $sdcFolder
  	;;
  'help')
    help
    ;;
  *)
    echo "Error: ${option} is an invalid run option"
    echo "Patch process aborted"
    help
    exit 1
    ;;
esac

exit 0

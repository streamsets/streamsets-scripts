#!/bin/sh
#
# Copyright (c) 2021 StreamSets Inc.
#
# This script looks for artifacts potentially affected by Log4J vulnerabilities CVE-2021-44228, CVE-2021-45046, CVE-2021-45105 and LOG4J2-3230

searchLogManager()
{
  jarPath=$1

  qLogManager=`jar tf $jarPath | grep LogManager.class | wc -l`
  if [ $qLogManager -gt 0 ]; then
    echo $jarPath - $qLogManager

    jar tf $jarPath | grep LogManager.class

    jarFile=`basename $jarPath`
    jarFolder=${jarPath##$rootFolder/}
    mkdir -p $jarFolder

    jar tf $jarPath | grep LogManager.class | while read javaClass; do outputLogManager $jarPath $jarFolder $javaClass; done
  fi
}

outputLogManager()
{
  jarPath=$1
  jarFolder=$2
  javaClass=$3

  unzip -d $jarFolder $jarPath $javaClass
}

rootFolder=$1

find $rootFolder -type f -name "*.jar" | while read jarPath; do searchLogManager $jarPath; done
grep -r --include "*.class" log4j2.loggerContextFactory .

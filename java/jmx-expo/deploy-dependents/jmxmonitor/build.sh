#!/bin/bash
set -x
set -e

mkdir -p release/libexec/jmxmonitor/lib/ 
mkdir -p release/libexec/jmxmonitor/temp/

mvn -U dependency:copy-dependencies -DoutputDirectory=release/libexec/jmxmonitor/lib/dependency/
mvn -U org.apache.maven.plugins:maven-dependency-plugin:2.8:get -DgroupId=com.kali.sre -DartifactId=jmxMonitor -Dversion=0.0.1-SNAPSHOT -Ddest=release/libexec/jmxmonitor/lib/
cp -r bin conf release/libexec/jmxmonitor/
mvn clean

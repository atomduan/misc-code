#!/bin/sh

set -e
set -x

JOB_ENV="job.activemq-standalone_service.activemq-standalone_cluster.local"
CLUSTER=`python ./deploy/find_cluster.py ${JOB_ENV}`

SCRIPT_DIR=`cd $(dirname $0); pwd -P`
cd $SCRIPT_DIR
rm -rf release

export SCRIPT_DIR
python ./deploy/installer.py ./deploy/activemq-installer.yaml

cp -r deploy release/

#!/bin/bash -x
#git branch -D feature_project_split
#git subtree split -P src -b feature_project_split
#git subtree add --prefix=src ../mifi-api/ feature_project_split
set -e

bn="$1"
shift 1
if [ -z "$bn" ]; then
    echo "branch name is empty"
    exit 1
fi

cd /home/mi/Workspace/miui/mifi-projects
if ! [ -d "mifi-ins-api" ] || ! [ -d "mifi-api" ]; then
    echo "project not exist"
    exit 1
fi

pushd mifi-ins-api
git checkout feature-mifi-api-split-$bn
popd

pushd mifi-api
git checkout $bn
git pull
git branch -D feature_project_split_$bn
git subtree split -P src -b feature_project_split_$bn
git checkout feature_project_split_$bn 
popd

pushd mifi-ins-api
git checkout feature-mifi-api-split-$bn
if [ -d "src" ]; then
    rm -r src
else
    echo "src not exsit"
fi
git add -A
git commit -m "del src $(date)"
git subtree add --prefix=src ../mifi-api feature_project_split_$bn
popd

#use this to append log
echo "" > /tmp/log.tmp
sv=""
pushd mifi-ins-api
git checkout feature-mifi-api-split-$bn
sv=$(git log | grep 'git-subtree-split' | sed -n '2p' | awk '{print $2}')
git log | grep 'git-subtree-split' | sed -n '1p' > /tmp/log.tmp
popd

if [ -z "$sv" ]; then
    echo "can not get the last version, exit"
    exit 0
fi

pushd mifi-api
git checkout feature_project_split_$bn
git pull
git log | sed -n "0,/${sv}/p" | sed '$d' | awk '{print "\t"$0}' >> /tmp/log.tmp
popd

pushd mifi-ins-api
git checkout feature-mifi-api-split-$bn
cat /tmp/log.tmp | git commit --amend --no-edit -F -
popd

pushd mifi-ins-api
#mvn clean package
if [ $?="0" ]; then
    echo "sync success"
else
    echo "sync fail"
fi
popd

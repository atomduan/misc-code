#! /bin/bash -
curr_path=$(cd `dirname $(which $0)`; pwd)
echo ${curr_path}
cd ${curr_path}

bpth=$(which btrace 2>/dev/null)
if [ -z ${bpth} ]; then
cat << END 
    btrace not installed yet...
    plz see "https://github.com/btraceio/btrace/blob/master/README.md" for more information
END
    exit 1
fi

cd mocksvr
javac HelloWorld.java

if ! [ -f HelloWorld.class ]; then
cat << END 
    compile HelloWorld.java fail...
END
    exit 1
fi

java HelloWorld > ${curr_path}/mocksvr.log 2>&1 &

h_pid=`ps -ef | grep HelloWorld | grep -v grep | awk '{print $2}'`
echo "Hello World pid is ${h_pid}, DONT FORGET TO KILL IT!"

trap "echo 'trap INT signal kill helloworld'; kill ${h_pid}" INT

cd ${curr_path}
cmd="btrace ${h_pid} samples/Timers.java"
eval ${cmd}

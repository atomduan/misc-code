#!/bin/bash -

project_home=/data1/warehouse
source ${project_home}/main/env.sh
source ${project_home}/main/util.sh 
current_path=$(cd `dirname $(which $0)`; pwd)
stage_home=$(cd ${current_path}; cd ../.; pwd)
time_stamp=`date +%s`

task_name="$1"                                                                                
shift 1                                                                                       
if [ -z "${task_name}" ]; then                                                                
    echo "[${current_path}]: task_name can not be EMPTY! exit."                               
    exit 1                                                                                    
fi                                                                                            
                                                                                              
month="$1"                                                                                    
shift 1                                                                                       
if [ -z "${month}" ]; then                                                                    
    echo "[${current_path}]: month can not be EMPTY! exit."                                   
    exit 1                                                                                    
fi                                                                                            
source ${stage_home}/stage.ini "${task_name}" "${month}"
source $current_path/generate_data_source_mapper.sh "${task_name}" "${month}"
if [ -z "${mapper_script_file_name}" ]; then
	echo "ERROR: mapper startup script file should not empty!"
	exit 1
fi

hadoop_jar="$curr_dir/hadoop_deps/hadoop-streaming-2.0.0-mr1-cdh4.4.0.jar"
scdh4_jar="$curr_dir/hadoop_deps/mapreduce-client.jar"
tools_jar="$curr_dir/hadoop_deps/hadooptool-hbase-1.1.6.jar"

mapper="${mapper_script_file_name}"
#input="${HDFS_SELECTED_RECOMPUTE_MERGE_FIELDS_ROOT}/${month}"
output="/tmp/yangming/kafka_mapper/${task_name}/${month}/${time_stamp}"
inputformat="com.yunrang.hadoop.app.common.input.combine.CombineRegionInputFormat"
outputformat="org.apache.hadoop.mapred.TextOutputFormat"
hbase_sql="select cf:* from weibo where datetime>=${startTime} and datetime<=${endTime};"
#reducer=reducer.py
archives=lib.tar.gz
function routine
{
    cmd="${hadoop_bin} jar $hadoop_jar \
        -libjars '$scdh4_jar,$tools_jar' \
        -D mapred.job.queue.name=recompute \
		-D mapred.map.tasks=6 \
        -D mapred.reduce.tasks=0 \
		-D hbase.mapreduce.sql=$hbase_sql \
        -archives ${archives}#lib \
        -output '${output}' \
        -inputformat $inputformat \
        -outputformat $outputformat \
        -mapper 'bash $mapper' \
        -file $mapper \
        -file kafka_client \
        "
    echo $cmd
    eval $cmd
}

routine
rm -rf ${mapper_script_file_name}


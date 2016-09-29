#!/bin/sh

if [ $# -lt 1 ]; then
    echo "Error: there must have a scriptfile param!"
    echo "Uasge: sh *.sh scriptfile [ begin_month end_month ]"
    exit 1
fi

scriptfile=$1

if [ $# -ge 2 ]; then
    yesterday=$2
else
    yesterday=`date -d yesterday '+%Y-%m-%d'`
fi

# logfile=/home/dev/daily_job/log/${yesterday}.log



echo "-------------------${yesterday} start at `date '+%Y-%m-%d %H:%M:%S'`-----------------" #>> ${logfile}


runscript=z_${scriptfile}
sed  "s/\$data_date/'${yesterday}'/g" ${scriptfile} > ${runscript}

echo "${scriptfile} partition(partition_date='${yesterday}')"

cat ${runscript}
hive -f "${runscript}"

echo "===================${yesterday} end at `date '+%Y-%m-%d %H:%M:%S'`===================" #>> ${logfile}



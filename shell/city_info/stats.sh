#!/bin/bash -
current_path=$(cd `dirname $(which $0)`; pwd)
project_home=`cd ${current_path}/..; pwd`
data_dir=${project_home}/target
nginx_home="/opt/nginx"

if ! [ -d "${data_dir}" ]; then
	mkdir -p ${data_dir}/result
	mkdir -p ${data_dir}/sql
fi

function find_files() {
	local days="$1"	
	shift 1
	find ${nginx_home}/logs -name 'access.*.log' -mtime -${days}
}

function cat_record() {
	local days="$1"	
	shift 1
	find_files ${days} |
		while read file;
		do
			cat $file
		done |
			awk -F'GET' '{print $2}' |
				awk -F 'HTTP' '{print $1}' |
					grep -E '/v[0-9]*/api' |
						grep -i '/main' |
							sort |
								uniq
}

function build_fetch_info_sql() {
	tokens_file="$1"
	shift 1
	if ! [ -d "${data_dir}/sql" ]; then
		mkdir -p ${data_dir}/sql
	fi

	#clean sql folder
	if [ -n "${data_dir}" ]; then
		rm ${data_dir}/sql/*
	fi

	#split if needed
	split -l 1000 ${tokens_file} ${data_dir}/sql/token_seg_

	find ${data_dir}/sql -name "token_seg_*" | 
		while read f;
		do
			fsql=`basename $f`.sql
			#gen head
			cat > ${data_dir}/sql/${fsql} << EOF
	select uinfo.uid,uinfo.school_id,sch.name,uinfo.city_id
	from (	
			select put.uid as uid ,put.token as token,pui.school_id as school_id, pui.city_id as city_id
			from passport.pp_user_token as put 
				left join passport.pp_user_info as pui on put.uid = pui.uid 
			where put.token in (
EOF
			#inject token to sql
			while read t;
			do
				echo "\"$t\"," >> ${data_dir}/sql/${fsql}
			done < <(cat $f)

			#add tail
			cat >> ${data_dir}/sql/${fsql} << EOF				
				"sentinaltoken"
			)
	) as uinfo 
		left join user.school as sch on uinfo.school_id = sch.id
EOF
		done
}

function fetch_userinfo() {
	find ${data_dir}/sql -name "*.sql" | 
		while read f;
		do
			${current_path}/mycmd `cat $f` 2>&1 |
				grep -v 'uid' |
					sort -s -k1,1 -n
		done
}

function parse_city_name() {
	uinfo="${data_dir}/userinfo.${days}.txt"
	shift 1
	cat $uinfo | 
		awk 'NF' | grep -vi 'null' |
			sort -n -k4,4 | 
				join -a1 -j1 4 -j2 1 - ${current_path}/code.txt |
					awk '{print $2,$3,$4,$1,$5}'
	cat $uinfo | grep -i 'null' 
}

function sync_final_resource() {
	echo "null" > /dev/null
}

function parse_record() {
	local days="$1"	
	shift 1
	cat_record ${days} > ${data_dir}/uniq_request.${days}.txt
	cat ${data_dir}/uniq_request.${days}.txt | 
		while read l; 
		do 
			tk=$(echo $l|grep -oE 'token=[^&]+?&'); 
			os=$(echo $l|grep -oE 'os=[^&]+&');
			echo $tk $os; 
		done |
			sort | uniq > ${data_dir}/filter_request.${days}.txt 

	ios_count=$(cat ${data_dir}/filter_request.${days}.txt |
		grep 'ios' | sort | uniq | wc -l)

	and_count=$(cat ${data_dir}/filter_request.${days}.txt |
		grep 'android' | sort | uniq | wc -l)

	if ! [ -d "${data_dir}/result" ]; then
		mkdir -p ${data_dir}/result
	fi

	cat > ${data_dir}/result/final_result_${days}.txt << EOF
---------------------------------------------------------------
Last ${days} Days Record
---------------------
Active users count:
$( echo "${ios_count} + ${and_count}" | bc )
---------------------
Active users in IOS:
${ios_count}
---------------------
Active users in ANDROID:
${and_count}


---------------------------------------------------------------
Last ${days} Days Distribution
---------------------
User (school, area) Distribution:

uid schoolId schoolName cityId cityName

EOF
	cat ${data_dir}/filter_request.${days}.txt | 
		awk '{print $1}' |
			sed 's/token=//g'|
				sed 's/&//g' |
					sort |
						uniq | 
							awk 'NF'> ${data_dir}/tokens.${days}.txt
	build_fetch_info_sql "${data_dir}/tokens.${days}.txt"
	#fetch data from mysql.....
	fetch_userinfo > ${data_dir}/userinfo.${days}.txt
	#parse city name from config
	parse_city_name >> ${data_dir}/result/final_result_${days}.txt
	sync_final_resource
}

echo "----------------------------------"
echo "$(date) Routine begin"
days=1
echo "compute ${days} stats"
parse_record "$days"
echo "compute ${days} stats complete"
echo "----------------------------------"

days=7
echo "compute ${days} stats"
parse_record "$days"
echo "compute ${days} stats complete"
echo "----------------------------------"

days=28
echo "compute ${days} stats"
parse_record "$days"
echo "compute ${days} stats complete"
echo "----------------------------------"

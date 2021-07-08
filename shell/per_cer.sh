#!/bin/bash -
cert_id=$@

if [ -z "$cert_id" ]; then
cat << EOF
cert_id can not be empty
USAGE: $0 cert_id
EOF
exit 1
fi

shard=$((cert_id>>51))

table="per_cer_${shard}"
echo "per_cert table is : ${table}"

#multi sql exec
mysql --host=10.118.26.188 --port=3306 --user=kkar --password=123456 --database=target_db --default-character-set=utf8 < <(cat << EOF
select * from ${table} where per_cer_id=${cert_id}\G;
EOF
)


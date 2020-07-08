#!/bin/bash -

#config below
certs_ids="3623 4197 4203 4205 4208 4209 5084"
seg_to_add=$({
    res=""
    while read line; do
        res="$res$(echo $line | awk 'NF' | awk '{print "\""$1"\""":""\""$2"\""","}')"
    done < <(echo "
2882303761517974491 AK47
2882303761517974491 AK48
2882303761517974491 AK49
2882303761517974491 AK50
2882303761517974491 AK51
")
    echo $res;
})

##################

place_holder="___AAA___SEG_TO_ADD___BBB___"
conn=$(cat db_mysql.sh | grep mysql | sed 's/${_E_}//g')
function fetch_blk_str_from_db() {
    gid=$1
    sqlcmd="$conn -e 'select exclude_apps from gift_cert where gift_cert_id = $gid'"
    eval $sqlcmd | sed 's/exclude_apps//g' \
                 | sed "s/^{/{${place_holder}/" \
                 | sed "s/${place_holder}/${seg_to_add}/"
}

function gen_alter_black_sql() {
    gid=$1
    blk_str=$(fetch_blk_str_from_db $gid | awk 'NF')
    sql="update gift_cert set exclude_apps='${blk_str}' where gift_cert_id=$gid;"
    echo $sql
}

{
    for gid in $certs_ids; do
        gen_alter_black_sql $gid
    done
} > /dev/stdout # > ./cert.sql

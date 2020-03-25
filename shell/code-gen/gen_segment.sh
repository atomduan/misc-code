#!/bin/bash -

sql_raw="mysql -h10.38.160.10 -pgan -utest -Dtest"

test_mysql_connectivity() {
    local table="$1"
    local desc_sql_cmd="${sql_raw} -e 'desc ${table};' 2>/dev/null"
    if eval "$desc_sql_cmd" | grep 'Field' > /dev/null; then
        echo "mysql connectivity check pass, codes will gen in ./gen_segment.snip file"
    else
        echo "mysql connectivity check NOT pass"
        exit 1
    fi
}

function gen_redis_bean_content() {
    local table="$1"
    local desc_sql_cmd="${sql_raw} -e 'desc ${table};' 2>/dev/null"
    eval "$desc_sql_cmd" | grep -v 'Field' | 
        awk -F'\t' '{print "    private "$2,system("echo "$1"|./camel_lower.py")}' | 
            sed '/^0$/d' | awk '{print $0";"}' |
                sed 's/int([0-9]*)/int/g' |
                    sed 's/varchar([0-9]*)/String/g' |
                        sed 's/timestamp/long/g' |
                            sed 's/datetime/long/g'
}

function gen_convert_util_content() {
    local table="$1"
    local desc_sql_cmd="${sql_raw} -e 'desc ${table};' 2>/dev/null"
    eval "$desc_sql_cmd" | grep -v 'Field' | 
        awk -F'\t' '{print system("echo "$1"|./camel_upper.py")}'  | sed '/^0$/d' | 
            awk '{print "r.set"$1"(t.get"$1"());"}' |
                awk '{if(NR==1) print $1; if(NR!=1) print "                    "$1;}'
}

function gen_thrift_content() {
    local table="$1"
    local desc_sql_cmd="${sql_raw} -e 'desc ${table};' 2>/dev/null"
    eval "$desc_sql_cmd" | grep -v 'Field' | 
        awk -F'\t' '{print " optional "$2,system("echo "$1"|./camel_lower.py")}' | 
            sed '/^0$/d' | awk '{print $0";"}' |
                sed 's/int([0-9]*)/int32/g' |
                    sed 's/varchar([0-9]*)/string/g' |
                        sed 's/timestamp/i64/g' |
                            sed 's/datetime/i64/g' | nl | tr -s " "  | sed 's/^ //g' |
                                awk '{print "    "$1":",$2,$3,$4}'
}

function gen_segment() {
local table_name="$1"
local beanupper=`echo ${table_name} | ./camel_upper.py`
local beanlower=`echo ${table_name} | ./camel_lower.py`
local tableupper=`echo ${table_name} | tr [a-z] [A-Z]`
local thriftbean="T${beanupper}"
local redis_bean_content=`gen_redis_bean_content ${table_name}`
local convert_util_content=`gen_convert_util_content ${table_name}`
local thrift_content=`gen_thrift_content ${table_name}`

cat << EOF
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
File : GanMetaCacheServiceImpl.java

    @Override
    public TGanMetaCacheResponse query${beanupper}Batch(TGanMetaCacheRequest request) throws TException {
        logger.info("Enter! request:{}",request);
        TGanMetaCacheResponse response = null;
        try {
            response =  fooMetaCacheBiz.query${beanupper}Batch(request);
        } catch (Exception e) {
            logger.error("INVOKE_FAIL,reason->{}", ExceptionUtils.getStackTrace(e));
            response =  new TGanMetaCacheResponse();
            response.setErrCode(Constants.META_INNER_ERROR);
            response.setErrMsg("META_INNER_ERROR");
        }
        response.setErrMsg("SUCCESS");
        logger.info("response:{}",response);
        return response;
    }

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
File : GanMetaRedisDAOFactory.java

        redisDAODict.put("${table_name}",new GanMetaRedisMultiDAO(redisClusterProxy,${beanupper}Redis.class,"${table_name}"));
        redisDAODict.get("${table_name}").setCacheSyncBiz(this.cacheSyncBiz);

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
File : ConvertUtil.java

    public static List<${thriftbean}> trans${beanupper}RedisToThrift(List<${beanupper}Redis> pc) {
        List<${thriftbean}> result = new ArrayList<${thriftbean}>();
        if (pc != null && pc.size() > 0) {
            for (${beanupper}Redis t: pc) {
                try {
                    ${thriftbean} r = new ${thriftbean}();
                    ${convert_util_content}
                    result.add(r);
                } catch (Exception e) {
                    logger.error("Convert fail, reason->{}", ExceptionUtils.getStackTrace(e));
                }
            }
        }
        return result;
    }

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
File : MetaModel.thrift

struct ${thriftbean} {
${thrift_content}
}

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
File : MetaService.thrift 

    MetaModel.TGanMetaCacheResponse query${beanupper}Batch(1:MetaRequest.TGanMetaCacheRequest request);

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
File : RedisKeyUtil.java 

            if ("${table_name}".equals(tagName)) {
                for (String id : ids) {
                    String rk = TableKey.get${beanupper}Key(Long.parseLong(id));
                    result.add(rk);
                }
            }

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
File : TableKey.java 

    private static final String ${tableupper} = "${table_name}";

    public static String get${beanupper}Key(long id) {
        return String.format(tableKeyTemplate, ${tableupper}, id);
    }

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
GEN File: src/main/java/com/shagou/foo/meta/cache/redis/bean/${beanupper}Redis.java

package com.shagou.foo.meta.cache.redis.bean;

import lombok.*;

@Data
public class ${beanupper}Redis {
${redis_bean_content}
}

EOF
}

table="gou_song"
#table="gou_song_t_map"
#table="gou_artist"
#table="gou_artist_t_map"
#table="gou_album"
#table="gou_list"
#table="gou_list_t_map"
#table="gou_list_songs"
#table="gou_album_artist_map"
#table="gou_song_artist_map"
#table="gou_billboard"
#table="gou_song_rate"
#table="gou_song_blacklist"
#table="t_category"
#table="t_category_list"
#table="gou_tag"
#table="gou_item_tags"

test_mysql_connectivity $table
gen_segment $table > gen_segment.snip

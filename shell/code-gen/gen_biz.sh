#!/bin/bash -

tables="gou_song
gou_song_t_map
gou_artist
gou_artist_t_map
gou_album
gou_list
gou_list_t_map
gou_list_songs
gou_album_artist_map
gou_song_artist_map
gou_billboard
gou_song_rate
gou_song_blacklist
t_category
t_category_list
gou_tag
gou_item_tags"

function gen_foo_cache_biz(){
cat << EOF
package com.shagou.foo.meta.cache.biz;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.shagou.foo.thrift.model.Constants;
import com.shagou.foo.thrift.model.meta.*;
import com.shagou.foo.thrift.request.meta.*;
import com.shagou.foo.meta.cache.redis.GanMetaRedisDAOFactory;
import com.shagou.foo.meta.cache.redis.dao.*;
import com.shagou.foo.meta.cache.redis.bean.*;
import com.shagou.foo.meta.cache.utils.ConvertUtil;
import com.shagou.foo.meta.cache.utils.RedisClusterProxy;;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.exception.ExceptionUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.*;



@Service
public class GanMetaCacheBiz {
    final static Logger logger = LoggerFactory.getLogger(GanMetaCacheBiz.class);

    @Autowired
    private GanMetaRedisDAOFactory fooMetaRedisDAOFactory;
EOF
for tn in $tables; do
    table_name="$tn"
    beanupper=`echo ${table_name} | ./camel_upper.py`
    beanlower=`echo ${table_name} | ./camel_lower.py`
    thriftbean="T${beanupper}"
cat << EOF

    public TGanMetaCacheResponse query${beanupper}Batch(TGanMetaCacheRequest request) {
        logger.info("Enter! request:{}",request);
        TGanMetaCacheResponse response = new TGanMetaCacheResponse();
        response.setErrCode(Constants.SUCCESS);
        long sysTime = System.currentTimeMillis();
        List<String> ids = request.getIds();
        try {
            GanMetaRedisDAO<${beanupper}Redis> fooMetaRedisDao =
                (GanMetaRedisDAO<${beanupper}Redis>) fooMetaRedisDAOFactory.getInstance("${table_name}");
            List<${beanupper}Redis> res = fooMetaRedisDao.queryBatchByIds(ids);
            List<${thriftbean}> tres = ConvertUtil.trans${beanupper}RedisToThrift(res);
            response.set${beanupper}Batch(tres);
            response.setErrMsg("SUCCESS");
        } catch (Exception e) {
            logger.error("PROCESS_FAIL,reason->{}", ExceptionUtils.getStackTrace(e));
            response.setErrCode(Constants.META_INNER_ERROR);
            response.setErrMsg("INNER_ERROR");
        }
        response.setSysTime(sysTime);
        return response;
    }
EOF
done
cat << EOF
}
EOF
}

#gen_foo_cache_biz > ../src/main/java/com/shagou/foo/meta/cache/biz/GanMetaCacheBiz.java

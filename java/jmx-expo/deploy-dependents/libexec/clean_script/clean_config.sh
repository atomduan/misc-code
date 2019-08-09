##########日志清理相关配置##########
#压缩COMPRESS_MINUTE_BEYOND分钟内没有修改过的日志文件
COMPRESS_MINUTE_BEYOND=240
#删除DELETE_DAY_BEYOND天前的日志文件
DELETE_DAY_BEYOND=35

#以下各目录配置置为空则表示不清理对应的项目
#清理的日志文件名字包括如下6种形式：xxxx.log.20121010, xxxx.log.2012101015, xxxx.log.20121010.1, xxx.log.2012101015.2, xxx.log.2012-10-10, xxx.log.2010-10-10-15

#各个服务的日志所在目录（一般包括resin中各web的日志、各中间层日志）
LOG_DIR_BASE="/home/work/log/default/kalo-service"


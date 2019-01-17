##########日志清理相关配置##########
#压缩COMPRESS_MINUTE_BEYOND分钟内没有修改过的日志文件
COMPRESS_MINUTE_BEYOND=10080
#删除DELETE_DAY_BEYOND天前的日志文件
DELETE_DAY_BEYOND=3650
#各个服务的日志所在目录（一般包括resin中各web的日志、各中间层日志）
LOG_DIR_BASE="/home/work/log/activity"


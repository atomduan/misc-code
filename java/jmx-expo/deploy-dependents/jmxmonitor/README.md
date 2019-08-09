# JMX监控数据接口

## 1 JMX监控
#### 1.1 JMX说明
JMX是Java Management Extension的缩写，J2SE5.0及更高版本都已经包含了JMX的标准实现。
JMX监控的主要功能：
- 报警分析
  如堆栈的使用率监控、线程数/句柄数监控、GC监控等等
- 应用调优
  堆栈、GC的数据方便JVM调整，也为容量提供数据支持

#### 1.2 监控程序说明
jmxmonitor.py主动向perf-counter推送数据;
perf-counter中搜索`jmx`即可看到采集项。

## 2 使用
#### 2.1 编译
###### 2.1.1 binary
output/目录下为已编译程序，可直接使用。

###### 2.1.2 源码
在`JDK 1.6`环境下编译
cd jmxMonitor/
mvn -U clean dependency:copy-dependencies package -Dmaven.test.skip=true
rm -rf output
mkdir output
mkdir output/lib
mv target/jmxMonitor-0.0.1-SNAPSHOT.jar output/lib/
mv target/dependency output/lib/
cp -R conf output/conf
cp -R bin output/bin
cp -R temp output/temp

#### 2.2 Java进程开启JMX端口
- 修改JDK的JMX配置文件，并设置jmxremote.password中的角色密码
cd $JAVA_HOME/jre/lib/management
cp jmxremote.password.template jmxremote.password
chmod 600 jmxremote.password
chmod 600 jmxremote.access

- 在启动文件中添加信息
JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.port=8090 \
-Dcom.sun.management.jmxremote.ssl=false \
-Dcom.sun.management.jmxremote.authenticate=true \
-Dcom.sun.management.jmxremote.password.file=$JAVA_HOME/jre/lib/management/jmxremote.password \
-Dcom.sun.management.jmxremote.access.file=$JAVA_HOME/jre/lib/management/jmxremote.access“

$JAVA_HOME/jre/lib/management/jmxremote.password定义角色及密码
$JAVA_HOME/jre/lib/management/jmxremote.access定义角色权限

#### 2.3 修改配置
在output/conf/collConf.ini中添加
```
service_name1:jmx_port1
service_name2:jmx_port2
...
```

如
```
voldemort:7811
KalocloudAPI:9234
```

#### 2.4 运行
```
cd output/bin && python jmxmonitor.py
```
可设置为crontab每分钟运行

## 3 监控数据
#### 3.1 java.lang
- MemPool_YongSpace_UseRate     | 年轻代使用率 (heap)
- MemPool_OldGen_UseRate        | 年老代使用率 (heap)
- MemPool_SurvivorSpace_UseRate | 幸存区使用率 (heap)
- MemPool_CodeCache_UseRate     | 代码缓存区使用率 (non-heap)
- MemPool_PermGen_UseRate       | Perm区使用率 (non-heap)
- MemPool_PermGenRO_UseRate     | 只读Perm区使用率 (non-heap)
- MemPool_PermGenRW_UseRate     | 读写Perm区使用率 (non-heap)
- MemPool_MetaSpace_UseRate     | MetaSpace区使用率(non-heap)
- GC_Major_Frequency | Major GC频率
- GC_Major_Time      | Major GC时间
- GC_Minor_Frequency | Minor GC频率
- GC_MinorGC_Time    | Minor GC时间
- ThreadCount             | 线程数
- TotalStartedThreadCount | 自JVM启动以来创建和启动的线程总数
- TotalPeakThreadCount    | 自JVM启动或峰复位以来的峰活动线程计数
- DaemonThreadCount       | 当前的活动守护线程数
- HeapMemoryUsage                | 当前Heap区使用的大小
- HeapMemoryUseRate              | 当前Heap区使用率
- NonHeapMemoryUsage             | 当前非Heap区使用的大小
- NonHeapMemoryUseRate           | 当前非Heap区使用率
- ObjectPendingFinalizationCount | 被挂起以便回收的object数
- LoadedClassCount      | 当前装入JVM的class数
- UnloadedClassCount    | 自JVM启动以来已卸载的class数
- TotalLoadedClassCount | 自JVM启动以来已装入的class数
- TotalCompilationTime | 编译所花费的累积时间 (ms)
- CpuUseRate  | CPU使用率
- OpenFDCount | 句柄数

#### 3.2 JMX自定义采集
步骤：
- 修改conf/collectConf.json，以json形式添加JMX自定义采集项
- 修改conf/counter.conf，添加JMX自定义采集组名
`注：如果JMX自定义采集项为空，将不进行输出`

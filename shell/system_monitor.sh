#!/bin/bash
# 系统信息监控脚本
# 功能一：提取操作系统的信息（内核、系统版本、网络地址等~）
# 功能二：分析系统运行状态（CPU负载、内存及磁盘使用率）
# 

# 清屏
clear
if [ $# -eq 0 ]; then
    echo " 系统信息"
    reset_terminal=$(tput sgr0)
    # check OS type 
    # 操作系统的类型
    os=$(uname -o)
    echo -e "\033[32;40m 操作系统类型：$os \033[0m"
    # check os Reloase version and name
    # 操作系统的版本类型
    # cat /etc/issue | grep "release"
    os_name=$(cat /etc/issue | grep -e "release")
    echo -e "\033[32;40m 操作系统版本：$os_name \033[0m"
    # CPU 型号 匹配到一行就终止
    CUP=$(cat /proc/cpuinfo | grep -m 1 'model name' |  awk '{print $4 " " $5 " " $6 " " $7 " " $8 " " $9 " " $10 " " $11}')
    echo -e "\033[32;40m cup型号：$CUP \033[0m"
    # CPU核数
    CUPS=$(lscpu | grep "^CPU(s)" | awk '{print $2}')
    echo -e "\033[32;40m cup核数：$CUPS \033[0m"
    # CPU总线程数
    processor=$(grep 'processor' /proc/cpuinfo | sort -u | wc -l)
    echo -e "\033[32;40m CPU总线程数：$processor \033[0m"
    # check architecture
    # CPU 位数
    architecture=$(uname -m)
    echo -e "\033[32;40m cup位数：$architecture \033[0m"
    # check kernel release
    # 内核版本
    kerner_release=$(uname -r)
    echo -e "\033[32;40m 内核版本：$kerner_release \033[0m"
    # check hostname
    # 主机名 或 uname -n 或 $HOSTNAME
    os_name=$(hostname)
    echo -e "\033[32;40m 主机名：$os_name \033[0m"
    # check internal ip
    # 内网的ip
    internalip=$(hostname -I | awk '{print $1}')
    echo -e "\033[32;40m 内网ip：$internalip \033[0m"
    # check external ip $NF 最后一行 以空格作为分隔符
    externalip=$(hostname -I | awk '{print $NF}')
    echo -e "\033[32;40m 公网ip：$externalip \033[0m"
    # check dns
    # dns 输出dns -E 边界控制符 awk筛选 以空格输出最后一段
    # cat /etc/resolv.conf | grep -E "\<nameserver[ ]+"|awk '{print $NF}'
    dns=$(cat /etc/resolv.conf | grep -E "\<nameserver[ ]+"|awk '{print $NF}')
    # DNS是多个的时候需要用到字符串分割 变成数组
    OLD_IFS="$IFS"
    # 用空格作为分隔符
    IFS=" "
    dns_arr=($dns)
    IFS="$OLD_IFS"
    for dns_one in ${dns_arr[@]}
    do
        # 循环 输出数据
        echo -e "\033[32;40m dns：$dns_one \033[0m"
    done
    # check if connected to internet or not
    # 网络是否连接
    # ping 两次 连接百度 输出到空设备中你 && 成功输出 || 失败输出
    # ping -c 2 baidu.com &> /dev/null && echo "网络是连通的" || echo "网络是不能连通的"
    ping -c 2 baidu.com &> /dev/null && echo " 网络是连通的" || echo " 网络是不能连通的"
    # check logged in users 
    # 单前用户登录数 
    # 输出结果以后 即时删除文件
    who>/tmp/who
    echo -e "\033[32;40m 已经登陆的用户：\n $(cat /tmp/who) \033[0m" 
    rm -f /tmp/who

    ############################## 内存分析
    echo " 内存分析"
    # 内存总计
    MemTotal_free=$(awk '/MemTotal/{MemTotal=$2} /MemFree/{MemFree=$2} /Buffers/{Buffers=$2} /^Cached/{Cached=$2}END{print MemTotal/1024}' /proc/meminfo)
    echo -e "\033[32;40m 内存总计：$MemTotal_free M \033[0m"
    # 系统内存
    server_free=$(awk '/MemTotal/{MemTotal=$2} /MemFree/{MemFree=$2} /Buffers/{Buffers=$2} /^Cached/{Cached=$2}END{print (MemTotal-MemFree)/1024}' /proc/meminfo)
    echo -e "\033[32;40m 系统使用内存：$server_free M \033[0m"
    # APP内存
    app_free=$(awk '/MemTotal/{MemTotal=$2} /MemFree/{MemFree=$2} /Buffers/{Buffers=$2} /^Cached/{Cached=$2}END{print (MemTotal-MemFree-Buffers-Cached)/1024}' /proc/meminfo)
    echo -e "\033[32;40m 应用软件使用内存：$app_free M \033[0m"
    # 空闲内存
    MemFree=$(grep MemFree /proc/meminfo | awk '{print $2/1024}')
    echo -e "\033[32;40m 空闲内存：$MemFree M \033[0m"
    ############################# cup运行状态
    # 也可以用 uptime 查看
    loadaverge=$(top -n 1 -b | grep "load average:"| awk '{print $12 "" $13 "" $14}')
    echo -e "\033[32;40m cup运行状态 一 五 十五分钟 平均负载：$loadaverge \033[0m"
    ############################# 磁盘使用量
    diskaverge=$(df -h | grep -vE 'Filesystem|tmpfs' | awk '{print $1 " " $2 " " $3 " " $5}')
    echo -e "\033[32;40m 磁盘使用率：$diskaverge \033[0m"
fi
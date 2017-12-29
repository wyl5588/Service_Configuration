##################################################
IP=`/sbin/ifconfig eth0|/bin/awk -F '[: ]+' 'NR==2{print $4}'`
ServerIP="124.207.22.2:9001"
ServerId=3
HOSTNAME="PLongMath"
DATE=`/bin/date +%T`
st=1
############################cpu#####################################
#取当前空闲cpu百份比值（只取整数部分）#取当前空闲cpu百份比值（只取整数部分）
cpu_idlee=`/usr/bin/top -b -n 1 | /bin/grep Cpu | /bin/awk '{print $5}' | /bin/cut -f 1 -d "."`
cpu_idle=`/usr/bin/expr 100 - ${cpu_idlee}`
if (($cpu_idle > 20)); then
 #status="服务器cpu使用率已经超过80%请及时处理."
 #status=${status:="服务器cpu使用率已经超过80%,请及时处理"}
 status=${status:="Server_cpu>80%,please_handle..."}
 st=0
fi
##############################内存################################
bu=`/usr/bin/free | /bin/awk 'NR==2{print $6}'`
ca=`/usr/bin/free | /bin/awk 'NR==2{print $7}'`
us=`/usr/bin/free | /bin/awk 'NR==2{print $3}'`
to=`/usr/bin/free | /bin/awk 'NR==2{print $2}'`
mem=`/usr/bin/expr "scale=2;($us-$bu-$ca)/$to" |/usr/bin/bc -l | /bin/cut -d. -f2`
if (($mem > 90)); then
 status=${status:="Server_memory>${mem}%,please_handle..."}
 st=0
fi
#################################网络##############################
eth_in_old=$(/sbin/ifconfig eth0|/bin/grep "RX bytes"|/bin/sed 's/RX bytes://'|/bin/awk '{print $1}')
eth_out_old=$(/sbin/ifconfig eth0|/bin/grep "RX bytes"|/bin/sed 's/.*TX bytes://'|/bin/awk '{print $1}')
sleep 1
eth_in_new=$(/sbin/ifconfig eth0|/bin/grep "RX bytes"|/bin/sed 's/RX bytes://'|/bin/awk '{print $1}')
eth_out_new=$(/sbin/ifconfig eth0|/bin/grep "RX bytes"|/bin/sed 's/.*TX bytes://'|/bin/awk '{print $1}')
eth_in=$(echo "scale=2;($eth_in_new - $eth_in_old)/1000.0"|/usr/bin/bc)
eth_out=$(echo "scale=2;($eth_out_new - $eth_out_old)/1000" | /usr/bin/bc)
network="${eth_in}KB/${eth_out}KB"
####################################磁盘###############################
#监控系统硬盘根分区使用的情况，当使用超过80%的时候发告警邮件,取当前根分区（/dev/sda3）已用的百份比值
disk_sda3=`/bin/df -h | /bin/grep /dev/sda3 | /bin/awk '{print $5}' | /bin/cut -f 1 -d "%"`
if (($disk_sda3 > 90)); then
 status=${status:="Server_Disk_root_partition>90%,please_handle..."}
 st=0
fi
###########################TCP/IP监控并发数############################
TCPIP=`/bin/netstat -na | /bin/grep ESTAB|/bin/awk '{print $4}'|/bin/grep :7780$|/usr/bin/wc -l`
######################15分钟系统负载抓取cpu的总核数##################
cpu_num=`/bin/grep -c 'model name' /proc/cpuinfo` #抓取15分钟系统负载
load_15=`/usr/bin/uptime | /bin/awk -F "," '{print $5}'|/bin/cut -d "." -f 1|/bin/sed s/[[:space:]]//g` #计算单个核心的负载。
average_load=`echo "scale=2;a=$load_15/$cpu_num;if(length(a)==scale(a)) print 0;print a" | /usr/bin/bc`
average_int=`echo $average_load | /bin/cut -f 1 -d "."` #取上面平均负载值的个位整数
#当单个核心15分钟的平均负载值大于等于1.0（即个位整数大于0） ，直接发邮件告警
if (($average_int > 0));then
 status=${status:="server_5_load:${average_int}>1_please_handle..."}
 st=0
fi
##########################################################################
#url可用性
URLSTATUS=`/usr/bin/curl -s -I -m 10 -o /dev/null -s -w %{http_code} "http://${IP}:7780/MintelRev/index.html"`
if [ $URLSTATUS -ne 200 ];then
  status=${status:="server_url_status:${URLSTATUS}please_handle..."}
  st=0
fi
###########################################################################
status=${status:='Running...'}
#S1="`curl http://${IP}:7780/MintelRev/UserSession.jsp -b /tmp/cookie123`"
#A=`curl http://183.224.72.89:7780/MintelRev/UserSession.jsp -b /tmp/cookie123`
#B=`cat  /opt/tomcat/logs/catalina.out |grep "^userId"|wc -l`
#S="${A}/${B}"
echo "hostname:$HOSTNAME"
echo "cpu: ${cpu_idle}%"
echo "mem: "${mem}%
echo "network-input:${eth_in}KB,output:${eth_out}KB"
echo "TCP/IP:${TCPIP}"
echo "disk: ${disk_sda3}%"
echo "Load: ${load_15}"
echo "URL: $URLSTATUS"
echo "状态:${st};信息:${status}"
echo "${DATE}"
###########################################################################
/usr/bin/curl  "http://${ServerIP}/save_data?serverName=${HOSTNAME}&serverID=${ServerId}&currentTime=${DATE}&serverIP=${IP}&currentCpu=${cpu_idle}%&currentMemory=${mem}%&session=000&netWork=${network}&disk=${disk_sda3}%&currentLink=${TCPIP}&loads=${load_15}&url=${URLSTATUS}&state=${st}&content=${status}"

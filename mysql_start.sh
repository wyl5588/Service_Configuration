mysql=/etc/init.d/mysqld
2 logpath=/tmp/mysql.log
3 portNum=`netstat -lnt|grep 3306|wc -l`
4 mysqlprocessNum=`ps -ef|grep mysqld |grep -v grep|wc -l`
5 if [ $portNum -eq 1 -a $mysqlprocessNum -eq 2 ];then
6 echo "db is runing"
7 else
8 $mysql start &>$logpath
9 sleep 10
10 portNum=`netstat -lnt|grep 3306|wc -l`
11 mysqlprocessNum=`ps -ef|grep mysqld |grep -v grep|wc -l`
12 if [ $portNum -ne 1 ] && [ $mysqlprocessNum -ne 2 ];then
13 while true
14 do
15 killall mysqld &>/dev/null
16 [ $? -ne 0 ] && break
17 sleep 1
18 done
19 $mysql start &>>$logpath && status="successful"|| status="failure"
20 mail -s "mysql startup status is $status" 1335234172@qq.com <$logpath
21 fi
22 fi
#获取mysql正常启动时获取端口的行数为1
#获取mysql正常启动时获取进程数为2
#判断这两个参数是不是同时满足，如果同时满足就判定mysql正常启动，打印db is runing
#如果有一个没有满足就 就重启mysql， 停留10s 再次反向检查，如果mysql 启动端口进程的行数不等于1,2就
#杀死mysql所有进程，用while循环实现多次杀死，当echo $? 为0时，认定mysql已彻底杀死
#停留1s 再次启动mysql 将启动信息保存日志，根据启动情况设定状态变量。并将信息发送到邮箱。
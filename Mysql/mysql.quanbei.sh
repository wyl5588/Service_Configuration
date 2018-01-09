#!/bin/bash
#时间
#mysql备份
export PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/mysql/bin:/root/bin
[ ! -d /server/backup/mysql_full ] && /bin/mkdir -p /server/backup/mysql_full && /bin/touch /server/backup/mysql_full/bak.log
export LANG=en_US.UTF-8
IPADDR=`/sbin/ifconfig|/bin/awk -F "[ :]+" 'NR==2{print $4}'`
BakDir=/server/backup/mysql_full/
LogFile=/server/backup/mysql_full/bak.log
Date=`/bin/date +%Y%m%d`
Begin=`/bin/date +"%Y-%m-%d %H:%M:%S"`
cd $BakDir
DATABASE="WordBuilder"
PORT=3306
DumpFile=${DATABASE}${Date}.sql
GZDumpFile=${DumpFile}.tgz
DBsock=/data/app/mysql-3306/mysql.sock
#mysqldump -uroot -pmintmath -h${IPADDR} -P${PORT} -B --master-data=2 --events --single-transaction --flush-logs ${DATABASE}> $DumpFile
/usr/local/mysql/bin/mysqldump -uroot -pmintmath -h${IPADDR} -P${PORT} -B --master-data=2 --events --single-transaction ${DATABASE}> $DumpFile
/bin/tar -czvf $GZDumpFile $DumpFile
GZFsize=`/usr/bin/du -sh ${DumpFile}|/bin/awk -F " " '{print $1}'`
/bin/rm -rf $DumpFile
##############################################
count=$(/bin/ls -l *.tgz |/usr/bin/wc -l)
if [ $count -ge 21 ]
then
file=$(/bin/ls -tl *.tgz |/bin/awk '{print $9}'|/bin/awk 'NR>=21')
rm -f $file
fi
#只保留过去3周的数据库内容
################################################
Last=`/bin/date +"%Y-%m-%d %H:%M:%S"`
GZfsizeS=`/bin/echo "$GZFsize"|sed "s/M//g"`
if [ $GZfsizeS -gt 500 ]
then
/bin/echo 开始:$Begin 结束:$Last $GZDumpFile succ >> $LogFile
else
echo 开始:$Begin 结束:$Last $GZDumpFile error >> $LogFile
fi
/server/scripts/mysql/wechat --corpid=wxf4c13f70d44c40b0  --corpsecret=So8bcvO80R2Y-dtkKKiQo964NKuHsnKiEvyUWIvFyF4   --msg="时间:${Last}
项目:南京数据全量备份
--------------------
服务器:${IPADDR}
端口:${PORT}
数据库:WordBuilder
大小:${GZFsize}
状态:Backup successful" --user=w1335234172  --agentid=1000002

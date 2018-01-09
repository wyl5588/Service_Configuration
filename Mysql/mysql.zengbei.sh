[ ! -d /server/backup/mysql_daily ] && mkdir -p /server/backup/mysql_daily && touch /server/backup/mysql_daily/binlog.log
export LANG=en_US.UTF-8
BakDir=/server/backup/mysql_daily/
LogFile=/server/backup/mysql_daily/binlog.log
BinDir=/data/app/mysql-3306/binlog/
BinFile=/data/app/mysql-3306/binlog/mysql-bin.index
IPADDR=`ifconfig|awk -F "[ :]+" 'NR==2{print $4}'`
PORT=3306
Counter=`wc -l $BinFile |awk '{print $1}'`
NextNum=0
for file in `cat $BinFile`
do
    base=`basename $file`
    NextNum=`expr $NextNum + 1`
    if [ $NextNum -eq $Counter ]
    then
        echo $base skip! >> $LogFile
    else
        dest=$BakDir/$base
        if(test -e $dest)
        then
            echo $base exist! >> $LogFile
        else
            cp -a $BinDir/$base $BakDir
            echo $base copying >> $LogFile
        fi
    fi
done
echo `date +"%Y年%m月%d日 %H:%M:%S"` Bakup succ! >> $LogFile
Last=`date +"%Y-%m-%d %H:%M:%S"`
mysqladmin -uroot -pmintmath -h${IPADDR} -P${PORT} flush-logs
/server/scripts/mysql/wechat --corpid=wxf4c13f70d44c40b0  --corpsecret=So8bcvO80R2Y-dtkKKiQo964NKuHsnKiEvyUWIvFyF4   --msg="时间:${Last}
项目:南京数据增量备份
--------------------
服务器:${IPADDR}
端口:${PORT}
日志:${base}
状态:Backup successful" --user=w1335234172  --agentid=1000002

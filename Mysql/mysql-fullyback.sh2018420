#!/bin/bash
# Program
# use mysqldump to Fully backup mysql data per week!
#全量备份脚本 
#History
# Path
FTP_Ip=36.110.111.53
FTP_UserName=transmit-data
FTP_PassWord=ftp-transmit
FTP_BackupDir=/mtmath

BakDir=/home/mysql/backup/		#####需要改成您服务器本地的文件目录，如果没有可以创建
LogFile=/home/mysql/backup/bak.log	#####需要改成您服务器本地的文件目录，如果没有可以创建
Date=`date +%Y%m%d`
Begin=`date +"%Y年%m月%d日 %H:%M:%S"`
cd $BakDir
DumpFile=$Date.sql
GZDumpFile=$Date.sql.tgz
###此处需要写您mysql的用户名和密码
mysqldump -uroot -proot --quick --events --all-databases --flush-logs --delete-master-logs --single-transaction > $DumpFile
tar -zvcf $GZDumpFile $DumpFile
rm $DumpFile
Last=`date +"%Y年%m月%d日 %H:%M:%S"`
echo 开始:$Begin 结束:$Last $GZDumpFile succ >> $LogFile

#上传到ftp写入日志
echo "(`date`) get data start ..." >> /root/data/getdata.log		#此处的文件目录页改成您本地相对应的目录
echo "==============================" >> /root/data/getdata.log		#此处的文件目录页改成您本地相对应的目录
lftp  <<EOF $FTP_Ip
	user $FTP_UserName $FTP_PassWord
	cd $FTP_BackupDir
	lcd $BakDir
	mput $GZDumpFile
	close
	bye
EOF

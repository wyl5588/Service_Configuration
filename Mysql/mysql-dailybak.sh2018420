#!/bin/bash
# Program
# use cp to backup mysql data everyday!
#增量备份脚本
# History
# Path
#增量备份时复制mysql-bin.00000*的目标目录，提前手动创建这个目录
BakDir=/home/mysql/backup/daily/	#####需要改成您服务器本地的文件目录，如果没有可以创建
#mysql的数据目录
BinDir=/var/lib/mysql/		#需要和您本地mysql的数据目录相对应
#mysql的index文件路径，放在数据目录下的
BinFile=/var/lib/mysql/mysql-bin.index	#需要和您本地mysql的数据目录相对应
LogFile=/home/mysql/backup/bak.log	#####需要改成您服务器本地的文件目录，记录日志用的，如果没有可以创建
FTP_Ip=36.110.111.53
FTP_UserName=transmit-data
FTP_PassWord=ftp-transmit
FTP_BackupDir=/mtmath

mysqladmin -uroot -proot flush-logs	#此处是您mysql的用户名和密码
#这个是用于产生新的mysql-bin.00000*文件
Counter=`wc -l $BinFile |awk '{print $1}'`
NextNum=0
#这个for循环用于比对$Counter,$NextNum这两个值来确定文件是不是存在或最新的

    
for file in `cat $BinFile`
do
    base=`basename $file`
    #basename用于截取mysql-bin.00000*文件名，去掉./mysql-bin.000005前面的./
    NextNum=`expr $NextNum + 1`
    if [ $NextNum -eq $Counter ]
    then
        echo $base skip! >> $LogFile
    else
        dest=$BakDir/$base
        if(test -e $dest)
        #test -e用于检测目标文件是否存在，存在就写exist!到$LogFile去
        then
            echo $base exist! >> $LogFile
        else
            cp $BinDir/$base $BakDir
            echo $base copying >> $LogFile
         fi
     fi
done
echo `date +"%Y年%m月%d日 %H:%M:%S"` $Next Bakup succ! >> $LogFile


#写入日志
echo "(`date`) get data start ..." >> /root/data/getdata.log		#此处的文件目录页改成您本地相对应的目录                                                                                                                                            
echo "=============================" >> /root/data/getdata.log		#此处的文件目录页改成您本地相对应的目录                                                                                                                                            
lftp  <<EOF $FTP_Ip							                                                                                                                                                                                   
	user $FTP_UserName $FTP_PassWord
	cd $FTP_BackupDir
	mirror -R --only-newer --verbose $BakDir
	close
	bye
EOF

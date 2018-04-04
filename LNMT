#!/bin/bash
# Author:  WangYunLong 
# Email:1335234172@qq.om
# BLOG:  http://bestyunyan.com
# Notes: OneinStack for CentOS-6.5 Centos7.2
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
clear
printf "
--------------------------------------------------------------------------
|                        Author:wangyunlong                              |
|                  Function: A key to install lamp                       |
|            This script is suitable for centos7 and centos6.5           |
-------------------------------------------------------------------------|
"
DJS(){
seconds_left=6
while [ $seconds_left -gt 0 ];do 
echo -n $seconds_left 
sleep 1 
seconds_left=$(($seconds_left - 1)) 
echo -ne "\r \r" 
done
}
# Check if user is root
if [ "$UID" -ne "0" ]; then echo "must be root run this csript";exit 1;fi
menu(){
cat << END
                    _____________________________ 
                    | ** (1).[install Nginx ] ** |
                    | ** (2).[install Tomcat] ** |
                    | ** (3).[install Mysql ] ** |
                    | ** (4).[install Lnmt  ] ** |
                    | ** (5).[-----Exit-----] ** |
-------------------------------------------------------------------------
|******************Please Enter Your Choice:[ 1-3]**********************|
-------------------------------------------------------------------------
END
}
while true
do
menu
read -t 60 -p "Please enter the installation number :" a
 echo "you selected $a server"
 case $a in
  1)
  echo "
  |=====================**Make Install Nginx-10.3**========================|"
  
  ;;
  2)
 echo " 
 |=====================**Make Install Tomcat-7**========================|"

echo "${seconds_left}秒后执行安装请稍等……"
DJS
#File md5 check
curl -o opt_tomcat7.0.75_jdk1.8.tgz "http://124.207.22.13/logs/Math/opt_tomcat7.0.75_jdk1.8.tgz"
echo "${seconds_left}秒后进行MD5校验请稍等……" 
DJS
cat > md5opt.txt <<EOF
868dfd0b2f27a5f33669f71c8b22f478  opt_tomcat7.0.75_jdk1.8.tgz
EOF
md5=`md5sum -c md5opt.txt|awk '{print $2}'`
if [ $md5 = "OK" ];
then 
   cat << END
----------------------------------------------------------------------
| NAME: opt_tomcat7.0.75_jdk1.8.tgz 
| SIZE: `du -sh "opt_tomcat7.0.75_jdk1.8.tgz"|awk '{print $1}'`
| CheckMD5:$md5                                                 
----------------------------------------------------------------------
"
END
else
echo
"
|----------------------------------------------------------------------
| NAME: opt_tomcat7.0.75_jdk1.8.tgz 
| SIZE: `du -sh "opt_tomcat7.0.75_jdk1.8.tgz"|awk '{print $1}'`
| CheckMD5:$md5                                                 
-----------------------------------------------------------------------
"
fi
echo "服务解压安装"
DJS
tar -xvzf $(pwd)/opt_tomcat7.0.75_jdk1.8.tgz -C /
echo "start tomcat..."
DJS
/opt/tomcat8080/bin/startup.sh && sleep 5 && ss -lntp|egrep "8080|8009|8005"
DJS
TomcatID=$(ps -ef|grep tomcat|grep /opt/tomcat8080|grep -v 'grep'|awk '{print $2}')
if [ -n $TomcatID ];then 
echo "------------------------------------------------------------"
echo "|Tomcat is starting...OK"
echo "------------------------------------------------------------"
else
echo "------------------------------------------------------------"
echo "|Tomcat not start..Error"
echo "------------------------------------------------------------"
fi
echo "${seconds_left}秒后返回首页……"
DJS
 ;;
  3)
 echo "
 |===================**Make Install Mysql-5.7.17**=======================|"
echo "安装依赖..."
DJS
yum install -y ncurses-devel libaio-devel -y
#定义变量
dyb(){
[ -f /etc/init.d/functions ] && . /etc/init.d/functions || exit 1
MYSQL_HOME="/usr/local/mysql"
MYSQL_TAR="/usr/local/src/mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz"
MYSQL_UNZIP_FILE="mysql-5.7.17-linux-glibc2.5-x86_64"
root_passwd="mintmath"
}
echo "添加用户组"
DJS
#设置mysql用户组
init_ug(){
id mysql
if [ "0" == "$?" ];then
echo "mysql用户存在，删除mysql用户和组" 
pid=`pidof mysqld`
kill -9 $pid >/dev/null 2>&1
/usr/sbin/userdel -r mysql > /dev/null 2>&1
echo "创建mysql用户和组!" && sleep 2
/usr/sbin/groupadd mysql
/usr/sbin/useradd -s /sbin/nologin -g mysql mysql
else
echo "创建mysql用户和组" && sleep 2
/usr/sbin/groupadd mysql
/usr/sbin/useradd -s /sbin/nologin -g mysql mysql
fi
}
#安装环境检查-基础环境配置
echo "基础环境配置+下载软件"
DJS
check_soft(){
for i in `rpm -qa mysql`;do rpm -e --nodeps $i;done
rm -rf /usr/local/mysql*
rm -rf /data/*
rm -rf /etc/init.d/mysqld_multi
rm -rf /etc/my.cnf &> /dev/null
rm -rf /etc/init.d/mysqld &>/dev/null
cd /usr/local/src
if [ ! -f ${MYSQL_TAR} ];then
curl -o mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz "http://124.207.22.13/logs/Math/mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz"
tar xvf /usr/local/src/mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz -C /usr/local/
ln -sv ${MYSQL_UNZIP_FILE} $MYSQL_HOME
else
tar xvf /usr/local/src/mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz -C /usr/local/
ln -sv ${MYSQL_UNZIP_FILE} $MYSQL_HOME
fi
}
#安装环境
mysql_install(){
#创建启动连接
echo "export PATH=$PATH:/usr/local/mysql/bin" >>/etc/profile
source /etc/profile
#添加帮助文档
echo "MANPATH /usr/local/mysql/man">>/etc/man.config
}
################单实例安装###############################
mysql_install_1_1(){
#创建数据存放目录
mkdir -p /data/3306/data
mkdir -p /data/3306/log
mkdir -p /data/3306/binlog
touch /data/3306/log/mysql.error
chown -R mysql.mysql /data
chmod -R 777 /data/*

#mysqld --verbose --help |more
#初始化
echo "初始化数据库"
DJS
/usr/local/mysql/bin/mysqld --initialize-insecure --user=mysql --basedir=/usr/local/mysql --datadir=/data/3306/data
[ $? -eq 0 ] && action "mysql 单实例初始化 成功" /bin/true || echo "mysql单实例初始化失败。。。" /bin/false 
#############复制配置文件和启动脚本
cp /usr/local/mysql/support-files/my-default.cnf /etc/my.cnf
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
###更改配置文件
echo "basedir=/usr/local/mysql
datadir=/data/3306/data
port=3306
server_id=1
socket=/data/3306/mysql.sock
symbolic-links=0
character_set_server=utf8
[client]
socket=/data/3306/mysql.sock" >>/etc/my.cnf
#sed -i 's#/usr/local/mysql#/opt/mysql#g' /opt/mysql/bin/mysqld_safe
}

mysqld_1_2(){
echo "启动数据库"
DJS
chkconfig --add /etc/init.d/mysqld
chkconfig mysqld on
echo "启动mysql..."
service mysqld start
#加密连接 
/usr/local/mysql/bin/mysql_ssl_rsa_setup
}
####################检测mysql是否安装成功############################
mysql_status_1_3(){
echo "启动状态检查"
DJS
if [ `netstat -lntp|grep 3306|wc -l` -eq 1 ]
then
action "mysql install 成功" /bin/true
else
action "mysql install 失败" /bin/false
fi
}
###############mysql密码设置打印库信息########################
passwd_1_4(){
echo "设置mysql的root管理密码！"
DJS
source ~/.bash_profile
mysqladmin -uroot password $root_passwd
mysql -uroot -p${root_passwd} -e "show databases;"
}
djs && dyb && init_ug && check_soft && mysql_install && mysql_install_1_1 && mysqld_1_2 && mysql_status_1_3 && passwd_1_4
 ;;
 4)
 echo "
 |===================**Make Install LNMA**================================|"
 ;;
  *|5)
 echo "exit,please reexecute."
 exit
 ;;
 esac
done

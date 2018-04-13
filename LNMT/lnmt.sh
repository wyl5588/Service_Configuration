#!/bin/bash
# Author:  WangYunLong 
# Email:1335234172@qq.om
# BLOG:  http://bestyunyan.com
# Notes: OneinStack for CentOS-6.5 Centos7.2
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
clear
printf "
--------------------------------------------------------------------------
|            This script is suitable for centos7 and centos6.5           |
-------------------------------------------------------------------------|
"
#################################################################################
#Check if user is root
if [ "$UID" -ne "0" ]; then echo "must be root run this csript";exit 1;fi
#Count down
DJS(){
seconds_left=6
while [ $seconds_left -gt 0 ];do 
echo -n $seconds_left 
sleep 1 
seconds_left=$(($seconds_left - 1)) 
echo -ne "\r \r" 
done
}
##################################################################################
install_nginx(){
#Download files
curl -o nginx-1.13.2.tar.gz "http://124.207.22.13/logs/Math/nginx-1.13.2.tar.gz"
curl -o nginx-sticky-module-1.26.zip "http://124.207.22.13/logs/Math/nginx-sticky-module-1.26.zip"
curl -o openssl-1.1.0b.tar.gz "http://124.207.22.13/logs/Math/openssl-1.1.0b.tar.gz"
curl -o opt_tomcat7.0.75_jdk1.8.tgz "http://124.207.22.13/logs/Math/opt_tomcat7.0.75_jdk1.8.tgz"
curl -o zlib-1.2.11.tar.gz "http://124.207.22.13/logs/Math/zlib-1.2.11.tar.gz"
curl -o pcre-8.41.tar.gz "http://124.207.22.13/logs/Math/pcre-8.41.tar.gz"
if [ `rpm -qa |grep -w gcc-c++ |wc -l` -ge 1 ] && [ `rpm -qa |grep -w gcc|wc -l` -ge 2 ];then echo "系统已安装gcc gcc-c++,编译环境检查通过";else echo "系统没有安装gcc或gcc-c++" &&  yum install -y gcc gcc-c++;fi
idir=`pwd`
#创建安装目录
if [ -d /usr/local/nginx ];then mv /usr/local/nginx /usr/local/nginx-bak`date +%Y%m%d%H%M`;mkdir -p /usr/local/nginx;else mkdir /usr/local/nginx;fi
cd /usr/local/nginx && ndir=`pwd` && cd $idir
#解压安装包
yum install -y unzip && unzip nginx-sticky-module-*.zip && tar -zxvf pcre-*.tar.gz && tar -zxvf zlib-*.tar.gz && tar -zxvf openssl-*.tar.gz && tar -zxvf nginx-*.tar.gz
#移走压缩包
mv *.zip /usr/local/src/ && mv *.tar.gz /usr/local/src/
#编译安装
cd pcre-* && pdir=`pwd`
./configure --prefix=/usr/local/pcre
make && make install
cd $idir
sleep 1
cd zlib-*
zdir=`pwd`
./configure --prefix=/usr/local/zlib
make && make install && cd $idir
sleep 1
cd openssl-* && odir=`pwd`
./config --prefix=/usr/local/openssl
make && make install
cd $idir
sleep 1
cd nginx-sticky-module-*
sdir=`pwd`
cd $idir
#加载文件库
echo '/usr/local/pcre/lib/' > /etc/ld.so.conf.d/pcre.conf
echo '/usr/local/zlib/lib/' > /etc/ld.so.conf.d/zlib.conf
echo '/usr/local/openssl/lib/' > /etc/ld.so.conf.d/openssl.conf
echo '/usr/local/lib/' > /etc/ld.so.conf.d/local.conf
cd nginx-1.*
./configure --prefix=$ndir --add-module=$sdir --with-http_stub_status_module --with-http_ssl_module --with-http_realip_module --with-http_gzip_static_module --with-openssl=$odir --with-pcre=$pdir --with-zlib=$zdir
make && make install && /usr/local/nginx/sbin/nginx || exit
cd ..
sleep 1
echo "`ps -ef|grep nginx`"
nginx=`netstat -tnlp | grep 80 | grep nginx | wc -l`
if [ "$nginx" -gt 0 ];then
echo "信息打印..."
echo "------------------------------------------------------------"
cat << END
----------------------------------------------------------------------
| 恭喜您Nginx安装成功!
| 服务: Nginx
| 端口：80 
| 状态: Already running...                                            
| 安装目录:/usr/local/nginx
----------------------------------------------------------------------
"
END
echo "------------------------------------------------------------"
else
echo "信息打印..."
echo "------------------------------------------------------------"
cat << END
----------------------------------------------------------------------
| 我靠!ginx启动失败!
| 服务: Nginx
| 端口：80 
| 状态: Already running...                                            
| 安装目录:/usr/local/nginx                                            
----------------------------------------------------------------------
"
END
echo "------------------------------------------------------------"
fi
}
##################################################################################
install_tomcat(){
echo "${seconds_left}秒后执行安装请稍等……";DJS
#Download files
curl -o opt_tomcat7.0.75_jdk1.8.tgz "http://124.207.22.13/logs/Math/opt_tomcat7.0.75_jdk1.8.tgz"
echo "${seconds_left}秒后进行MD5校验请稍等……" ;DJS
cat > md5opt.txt <<EOF
868dfd0b2f27a5f33669f71c8b22f478  opt_tomcat7.0.75_jdk1.8.tgz
EOF
md5=`md5sum -c md5opt.txt|awk '{print $2}'`
if [ $md5 = "OK" ];then 
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
";fi
echo "解压并安装Tomcat.....";DJS
tar -xvzf $(pwd)/opt_tomcat7.0.75_jdk1.8.tgz -C /
echo "start tomcat...";sleep 2 
/opt/tomcat8080/bin/startup.sh && sleep 5 && ss -lntp|egrep "8080|8009|8005"
echo "信息打印..."
DJS
TomcatID=$(ps -ef|grep tomcat|grep /opt/tomcat8080|grep -v 'grep'|awk '{print $2}')
if [ -n $TomcatID ];then 
echo "------------------------------------------------------------"
cat << END
----------------------------------------------------------------------
| 恭喜您Tomcat安装成功... 
| 服务: Tomcat
| 状态: Already running...
| 安装目录:/opt/tomcat8080                                               
----------------------------------------------------------------------
"
END
echo "------------------------------------------------------------"
else
echo "------------------------------------------------------------"
cat << END
----------------------------------------------------------------------
| 我靠! Tomcat启动失败...
| 服务: Tomcat
| 状态: Startup failure...
| 安装目录:/opt/tomcat8080                                               
----------------------------------------------------------------------
"
END
echo "------------------------------------------------------------"
fi
echo "${seconds_left}秒后返回首页……";DJS
}
##################################################################################
#install_mysql
dyb(){
yum install -y ncurses-devel libaio-devel -y
[ -f /etc/init.d/functions ] && . /etc/init.d/functions || exit 1
MYSQL_HOME="/usr/local/mysql"
MYSQL_TAR="/usr/local/src/mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz"
MYSQL_UNZIP_FILE="mysql-5.7.17-linux-glibc2.5-x86_64"
root_passwd="mintmath"
}
###################################################################
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
###################################################################
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
##################################################################
mysql_install(){
#创建启动连接
echo "export PATH=$PATH:/usr/local/mysql/bin" >>/etc/profile
source /etc/profile
#添加帮助文档
echo "MANPATH /usr/local/mysql/man">>/etc/man.config
}
###################################################################
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
}
###############################################################
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
##############################################################
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
###############################################################
passwd_1_4(){
echo "设置mysql的root管理密码！"
source ~/.bash_profile
mysqladmin -uroot password $root_passwd
mysql -uroot -p${root_passwd} -e "show databases;"
echo "信息打印...."
DJS
echo "------------------------------------------------------------"
cat << END
----------------------------------------------------------------------
| 恭喜您Mysql服务安装成功..
| 端口：3306
| 用户名密码:root:mtmath
| 状态: Startup failure...
| 安装目录:/usr/local/mysql                                              
----------------------------------------------------------------------
"
END
echo "##################################################################"
}
install_mysql(){
DJS && dyb && init_ug && check_soft && mysql_install && mysql_install_1_1 && mysqld_1_2 && mysql_status_1_3 && passwd_1_4
}
##################################################################################
install_lnmt(){
 install_nginx &&  install_tomcat &&  install_mysql && echo "信息显示......" && DJS && clear
echo "------------------------------------------------------------"
/usr/sbin/ss -lntp|egrep "8080|8005|8009|80|3306"|column -t
 cat << END
----------------------------------------------------------------------
|恭喜您安装服务:nginx tomcat mysql 成功! 
|详细信息:
|Nginx:/usr/local/nginx
|Tomcat:/opt/tomcat8080
|Mysql:/usr/local/mysql
|Nginx[80],Tomcat[8080],Mysql[3306]                                             
----------------------------------------------------------------------
"
END
echo "######################################################################"
exit
}
##################################################################################
#Display Menu
menu(){
#clear
cat << END
                  ___________________________________   
                 |______A KEY TO INSTALL lAMT_______|
                    |\_____Wang_yun_long________/|
                    | ** (1).[install Nginx ] ** |
                    | ** (2).[install Tomcat] ** |
                    | ** (3).[install Mysql ] ** |
                    | ** (4).[install Lnmt  ] ** |
                    | ** (5).[-----Exit-----] ** |
-------------------------------------------------------------------------
|            This script is suitable for centos7 and centos6.5          |
-------------------------------------------------------------------------
|******************Please Enter Your Choice:[ 1-3]**********************|
-------------------------------------------------------------------------
END
}
####################################################################################
while true
do
menu
read -t 60 -p "Please enter the installation number :" a
 echo "you selected $a server"
 case $a in
  1)
  echo "
  |=====================**Make Install Nginx-10.3**========================|"
  install_nginx && echo "5s后返回首页.." && DJS
  ;;
  2)
 echo " 
 |=====================**Make Install Tomcat-7**========================|"
 install_tomcat && echo "5s后返回首页.." && DJS
 ;;
  3)
 echo "
 |===================**Make Install Mysql-5.7.17**=======================|"
install_mysql && echo "5s后返回首页.." && DJS
 ;;
 4)
 echo "
 |===================**Make Install LNMA**================================|"
 install_lnmt
 ;;
  *|5)
 echo "exit,please reexecute."
 exit
 ;;
 esac
done

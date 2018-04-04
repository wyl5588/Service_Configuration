yum install -y ncurses-devel libaio-devel -y
#倒计时3秒
djs(){
seconds_left=3
echo "${seconds_left}秒后后执行安装程序请稍等……" 
while [ $seconds_left -gt 0 ];do 
echo -n $seconds_left 
sleep 1 
seconds_left=$(($seconds_left - 1)) 
echo -ne "\r \r" #清除本行文字 
done
}
####################################################
#定义变量
dyb(){
[ -f /etc/init.d/functions ] && . /etc/init.d/functions || exit 1
MYSQL_HOME="/usr/local/mysql"
MYSQL_TAR="/usr/local/src/mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz"
MYSQL_UNZIP_FILE="mysql-5.7.17-linux-glibc2.5-x86_64"
root_passwd="mintmath"
}
##############################################
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
########################################################
#安装环境检查-基础环境配置
check_soft(){
for i in `rpm -qa mysql`;do rpm -e --nodeps $i;done
rm -rf /usr/local/mysql*
rm -rf /data/*
rm -rf /etc/init.d/mysqld_multi
rm -rf /etc/my.cnf &> /dev/null
rm -rf /etc/init.d/mysqld &>/dev/null
cd /usr/local/src
if [ ! -f ${MYSQL_TAR} ];then
curl http://124.207.22.13/logs/Math/mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz
tar xvf /usr/local/src/mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz -C /usr/local/
ln -sv ${MYSQL_UNZIP_FILE} $MYSQL_HOME
else
tar xvf /usr/local/src/mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz -C /usr/local/
ln -sv ${MYSQL_UNZIP_FILE} $MYSQL_HOME
fi 
}
##########################################################################
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
#如果mysql没有安装在/user/localmysql下那么需要执行上面的步骤体会为opt/mysql
}
########################################################################
##mysql单实例启动
mysqld_1_2(){
chkconfig --add /etc/init.d/mysqld
chkconfig mysqld on
echo "启动mysql..."
service mysqld start
#加密连接 
/usr/local/mysql/bin/mysql_ssl_rsa_setup
}
####################检测mysql单实例是否安装成功############################
mysql_status_1_3(){
echo "mysql install status check"
if [ `netstat -lntp|grep 3306|wc -l` -eq 1 ]
then 
action "mysql install 成功" /bin/true
else 
action "mysql install 失败" /bin/false
fi
}
###############mysql单实例密码设置打印库信息########################
passwd_1_4(){
echo "设置mysql的root管理密码！" && sleep 2
source ~/.bash_profile
mysqladmin -uroot password $root_passwd
mysql -uroot -p${root_passwd} -e "show databases;"
}
#####################################################################
djs && dyb && init_ug && check_soft && mysql_install && mysql_install_1_1 && mysqld_1_2 && mysql_status_1_3 && passwd_1_4 

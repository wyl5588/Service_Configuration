##############################################
#!bin/bash                                   #
#Author:王云龙                               #
#Emial:1335234172@qq.com                     #
#explain:Create a personal working directory;#
##############################################

#Create working directory;
echo "Create working directory;";sleep 1;
/bin/mkdir -p /server/scripts /server/backup/web_backup /server/backup/mysql_backup /server/tools /server/tmp/;
/bin/mkdir -p /.trash

#Error - proof operation:[rm -rf];
echo "Error - proof operation:[rm -rf]";sleep 1;
/bin/echo 'TRASH_DIR="/.trash"    
for i in $*; do  
    STAMP=`date +%s`  
    #fileName=`basename $i`  
    mv $i $TRASH_DIR/ &>/dev/null 
done
' >/server/scripts/remove.sh
chmod +x /server/scripts/remove.sh
echo 'alias rm="/server/scripts/remove.sh"' >> /root/.bashrc
source /root/.bashrc

#set ulimit=65535
echo "set ulimit=65535";sleep 1;
echo "ulimit -SHn 65535" >>/etc/rc.local
cat >> /etc/security/limits.conf << EOF
*       soft    nofile  65535
*       hard    nofile  65535
EOF

#Delete unnecessary user groups
echo "Delete unnecessary user groups";sleep 1;
userdel adm;userdel lp;userdel sync;userdel shutdown;userdel halt
userdel uucp;userdel operator;userdel games;userdel gopher;userdel ftp
groupdel adm;groupdel lp;groupdel dip

#Setting the system Yum source
echo "Setting the system Yum source";sleep 1;
mkdir -p /etc/yum.repos.d/bak;mv /etc/yum.repos.d/* /etc/yum.repos.d/bak/
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
yum -y install wget
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
yum clean all &>/dev/null
yum makecache &>/dev/null
#curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
#wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

#Installation update system necessary software
echo "Installation update system necessary software"
yum install tree nmap sysstat lrzsz dos2unix curl vim-enhanced -y
yum -y install pcre-devel openssl openssl-devel
yum install -y install -y pcre* lib* pcre-devel* -y
yum install -y yum -y install gcc* gcc-c++ make
yum -y update glibc\*;yum -y clean all
#yum -y update

#Adjust the number of file descriptors
echo "Adjust the number of file descriptors";sleep 1;
/bin/cp /etc/security/limits.conf /etc/security/limits.conf.bak
echo '* -   nofile  65535'>>/etc/security/limits.conf

#Change character set
echo "Change character set"
/bin/cp /etc/sysconfig/i18n /etc/sysconfig/i18n.bak
echo 'LANG="en_US.UTF-8"' >/etc/sysconfig/i18n

#Change system time zone
echo "Change system time zone"
yum -y install ntp
echo "* 3 * * * /usr/sbin/ntpdate edu.ntp.org.cn &>/dev/null " >> /etc/crontab
service crond restart


#close selinux and iptables
echo "close selinux and iptables"
iptables-save >/etc/sysconfig/iptables_$(date +%s)
iptables -F;service iptables stop
setenforce 0
sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config

#Simplify system boot item（crond,sshd,network,syslog)
echo "Simplify system boot item（crond,sshd,network,syslog,auditd)";sleep 1;
for i in `chkconfig --list |grep 3:on |awk '{print $1}'`;do chkconfig --level 3 $i off;done
for i in {crond,sshd,network,auditd,rsyslog};do chkconfig --level 3 $i on;done


#SSH Remote Login timeout 3600s and Add backup account 
echo "#SSH Remote Login timeout 3600s and Add backup account"
echo "#The history command record number is set to 100;" sleep 1;
echo "TMOUT=3600">> /etc/profile
sed -i "s/HISTSIZE=1000/HISTSIZE=100/" /etc/profile;source /etc/profile
/bin/cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sed -i 's/\#PermitEmptyPasswords no/PermitEmptyPasswords no/' /etc/ssh/sshd_config
sed -i 's/#useDNs yes/UseDNS no/' /etc/ssh/sshd_config
#sed -i 's/\#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
service sshd restart


#Optimization of system kernel parameters
echo "Optimization of system kernel parameters";sleep 1;
/bin/cp -a /etc/sysctl.conf /etc/sysctl.conf.back
modprobe bridge
echo "modprobe bridge">> /etc/rc.local
echo "modprobe nf_conntrack">> /etc/rc.local
echo '
net.ipv4.tcp_max_syn_backlog = 65536
net.core.netdev_max_backlog = 32768
net.core.somaxconn = 32768
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_tw_recycle = 1
#net.ipv4.tcp_tw_len = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_max_orphans = 3276800
#net.ipv4.tcp_fin_timeout = 30
#net.ipv4.tcp_keepalive_time = 120
net.ipv4.ip_local_port_range = 1024 65535'>/etc/sysctl.conf
/sbin/sysctl -p


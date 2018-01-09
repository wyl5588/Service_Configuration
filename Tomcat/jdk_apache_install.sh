#!bin/bash
cp -a /server/tools/apache-tomcat-7.0.70.tar.gz /opt/
cp -a /server/tools/jdk-8u101-linux-i586.tar.gz /opt/
cd /opt/
tar -xvzf apache-tomcat-7.0.70.tar.gz && 
tar -xvzf jdk-8u101-linux-i586.tar.gz && 
ln -s /opt/jdk1.8.0_101 /opt/jdk && 
ln -s /opt/apache-tomcat-7.0.70 /opt/tomcat && 
sed -i '107a export JAVA_HOME=/opt/jdk' /opt/tomcat/bin/catalina.sh && 
sed -i '108a export PATH=${JAVA_HOME}/bin:$PATH' /opt/tomcat/bin/catalina.sh
/opt/tomcat/bin/startup.sh
ss -lntp|grep 8
ps -ef|grep tomcat
echo "/opt/tomcat/bin/startup.sh" >>/etc/rc.local




#!/bin/bash
#export LANG=zh_CN.UTF-8
#nginx一键安装,nginx安装路径是与当前文件夹同级的nginx目录
#已增加openssl sticky模块
#jcs
#DATE 2017-07-28

if [ `rpm -qa |grep -w gcc-c++ |wc -l` -ge 1 ] && [ `rpm -qa |grep -w gcc|wc -l` -ge 2 ];then
  echo "系统已安装gcc gcc-c++,编译环境检查通过"
else
  echo "系统没有安装gcc或gcc-c++"
  exit 1
fi

idir=`pwd`
#创建安装目录
if [ -d ../nginx ];then
  mv ../nginx ../nginx-bak`date +%Y%m%d%H%M`
  mkdir ../nginx
else 
  mkdir ../nginx
fi

cd ../nginx
ndir=`pwd`
cd $idir

#解压安装包
unzip nginx-sticky-module-*.zip
tar -zxvf pcre-*.tar.gz
tar -zxvf zlib-*.tar.gz
tar -zxvf openssl-*.tar.gz
tar -zxvf nginx-*.tar.gz

#移走压缩包
mkdir install-bak`date +%H%M%S`
mv *.zip install-bak*
mv *.tar.gz install-bak*

#编译安装
cd pcre-*
pdir=`pwd`
./configure --prefix=/usr/local/pcre
make && make install
cd $idir
sleep 1

cd zlib-*
zdir=`pwd`
./configure --prefix=/usr/local/zlib
make && make install
cd $idir
sleep 1

cd openssl-*
odir=`pwd`
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
make && make install
cd ..
sleep 1

#libpcre.so问题
#uname -r | grep _64
#if [ $? -eq 0 ];then
#  ln -s /usr/local/lib/libpcre.so.1 /lib64/
#else
#  ln -s /usr/local/lib/libpcre.so.1 /lib/
#fi

echo
echo
echo "    恭喜! nginx安装完成!         nginx的安装路径是$ndir"
echo
echo

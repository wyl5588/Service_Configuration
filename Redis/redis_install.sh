yum install gcc-c++
yum install -y tcl*
wget http://download.redis.io/releases/redis-2.8.13.tar.gz && 
tar -xzvf redis-2.8.13.tar.gz && 
mv redis-2.8.13 /usr/local/redis && 
cd /usr/local/redis && 
make && make install && 
mkdir -p /etc/redis && 
cp redis.conf /etc/redis &&　
sed -i 's/daemonize no/daemonize yes/g' /etc/redis/redis.conf && 
/usr/local/bin/redis-server /etc/redis/redis.conf && 
ps -ef | grep redis

#!/usr/bin/expect -f
#############################
ab=`rpm -qa expect |wc -l`
if [ ${ab} -eq 0 ]
then
   yum install -y expect
fi
##############################
cd /server/scripts/
for i in `cat /server/tmp/ip.txt`
do
./fabu.sh $i
done
#############################

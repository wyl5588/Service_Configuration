. /etc/init.d/functions
 function check_ok(){
  if [ $? -eq 0 ]
   then
     echo ""
     continue
  else
     echo "pls check error"
     exit
  fi
}

yum install keepalived -y
rpm -qa keepalived
/etc/init.d/keepalived start
ps -ef |grep keep|grep -v grep
check_ok
action "keepalived install ok" /bin/true
exit

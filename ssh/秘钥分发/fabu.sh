#!/usr/bin/expect -f
set ip [lindex $argv 0 ]
set password 123456
set timeout 10
spawn ssh-copy-id -i /root/.ssh/id_rsa.pub $ip
expect {
"*yes/no" { send "yes\r"; exp_continue }
"*password:" { send "123456\r" }
}
expect "#"
send "/bin/chmod 700 /root/.ssh/\t"
expect "#"
send "/bin/chmod 600 /root/.ssh/authorized_keys\t"
expect eof


#!/bin/bash -

addr=$1
shift
port=$1
shift
user=$1
shift
passwd=$1
shift
dest=$1
shift
src=$1
shift

cmd="scp -P ${port} -r ${src} ${user}@${addr}:${dest}"

echo "cmd is : ${cmd}"
echo "password is : $passwd"
expect -c "
spawn ${cmd}
expect {
    \"password:\" { send -- \"${passwd}\r\";}
}
expect eof
"

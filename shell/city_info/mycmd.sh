#!/bin/bash -
host="192.168.1.166"
port="3308"
user="dummy_user"
password="your_password"

cmd="$@"
mysql --default-character-set=utf8 --host="$host" --port="$port" --user="$user" --password="$password" -e "${cmd}"

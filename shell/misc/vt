#!/bin/bash -
clear

filename="$1"
shift 1

if [ -z "$filename" ]; then
	echo "filename can not be empty"
	exit 1;
fi


is_empty=1
count=0

condition=""
if echo $filename | grep '/'; then
	condition="find . -type f | grep -iE '$filename'"
else
	condition="find . -iname '*$filename*' -type f"
fi

cmd="$condition | sort |grep -vE \"(target|classes|src/test|\.swp$)\" "

function openvim() {
	filecount="$@"
	filepath=`eval $cmd | sed -n "${filecount}p" 2>/dev/null`
	if ! [ -f "$filepath" ]; then
		echo "file does not exit, filecount input is [$filecount]"
		return
	fi
	vi -b $filepath
}

filecount=`echo "$1" | grep -oE '[0-9]+'`
shift 1

if [ -n "$filecount" ]; then
	openvim $filecount
	exit 0
fi

while read line; 
do 
	is_empty=0;
	echo $line | grep -i $filename --color;
	count=$(( $count+1 ))
done< <(eval $cmd |awk 'BEGIN{c=1}{print c"\t"$0;c=c+1}')

if [ $count -eq 1 ]; then
	openvim "1" 
	exit 0
fi

if [ $is_empty -eq 1 ]; then
	echo "no file match the pattern: $filename"	
	exit 1
fi

echo -n "Enter the file you selected:"

filecount=`head -1 /dev/stdin | grep -oE '[0-9]+'`
if [ -z "$filecount" ]; then
	echo "invalid filecount"
	exit 1
fi

openvim $filecount
exit 0

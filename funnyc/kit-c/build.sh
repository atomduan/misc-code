#!/bin/bash -
curr=$(cd `dirname $(which $0)`; pwd)

name=`echo $1 | sed 's/\.c//g'`
if [ -z "${name}" ]; then
    echo "./build.sh <name>, name can not be empty"
    exit 1
fi

cd $curr

make clean 2>/dev/null

cat <<EOF > Makefile
CC=clang 
CFLAGS=-c -pipe -O0 -W -Wall -Wpointer-arith -Wno-unused-parameter -Werror -g
LDFLAGS=-L/usr/local/opt/bison/lib

LINK=\$(CC)
BUILD_DEPS=./kit_unit_case.h
BUILD_INCS=-I ./

unit_case: ${name}.o
	\$(LINK) -o unit_case.bin ${name}.o \
	-ldl -lpthread -lm -Wl \$(LDFLAGS)

${name}.o:	\$(BUILD_DEPS)
	\$(CC) \$(CFLAGS) \$(BUILD_INCS) -o ${name}.o ${name}.c

show_prep:	\$(BUILD_DEPS)
	\$(CC) \$(CFLAGS) \$(BUILD_INCS) -E ${name}.c

.PHONY:clean
clean:
	rm -rf *.o *.bin core *.output Makefile
EOF
make

if [ -x unit_case.bin ]; then

cat << EOF


---------------MISC RUN-----------------


EOF
    ./unit_case.bin
cat << EOF


---------------MISC FIN-----------------


EOF
fi

make clean 2>/dev/null

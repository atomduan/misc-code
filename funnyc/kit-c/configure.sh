#!/bin/bash -
curr=$(cd `dirname $(which $0)`; pwd)
cmd=`basename $0`
cd $curr

# parse option
opt_template=`getopt -o e --long exe,execute -n "$cmd" -- "$@"`
if [ $? != 0 ]; then echo "opt parse fail, terminating..." >&2; exit 1; fi
# shuffle args make sure '--' can delimit between opts and args
eval set -- "$opt_template"
echo "opt parse res:<< $opt_template >>"

# parse option flags
auto_build_flag="FALSE"
while true; do
    case "$1" in
        -e|--exe|--execute)
            auto_build_flag="TRUE"
            shift
            ;;
        --)
            # terminate mark, all opt parse finished 
            shift 1
            break
            ;;
        *)
            echo "internal error!"
            exit 1
            ;;
    esac
done

# parse source file name *.c
name=""
for arg do
    name="$arg"
    name=`echo $name | sed 's/\.c//g'`
    name=`echo $name | sed 's/\.$//g'`
    break
done
if [ -z "${name}" ]; then
    echo "./$cmd -e|--exe <name>, name can not be empty"
    exit 1
fi

# make file config
make clean 2>/dev/null
cat <<EOF > Makefile
CC=clang 
CFLAGS=-c -pipe -O0 -W -Wall -Wpointer-arith -Wno-unused-parameter -Werror -g
LDFLAGS=-L/usr/local/opt/bison/lib

LINK=\$(CC)
BUILD_DEPS=./kit_sys.h
BUILD_INCS=-I ./

${name}: ${name}.o
	\$(LINK) -o ${name}.bin ${name}.o \
	-ldl -lpthread -lm -Wl \$(LDFLAGS)

${name}.o:	\$(BUILD_DEPS)
	\$(CC) \$(CFLAGS) \$(BUILD_INCS) -o ${name}.o ${name}.c

prep:	\$(BUILD_DEPS)
	\$(CC) \$(CFLAGS) \$(BUILD_INCS) -E ${name}.c

.PHONY:clean
clean:
	rm -rf *.o *.bin core *.output
EOF

# build and execute binary or not..
if [ "x$auto_build_flag" = "xTRUE" ]; then
    echo "auto_build_flag set to 'TRUE', try make and run binary......"
cat << EOF
---------------KIT BUILD---------------
EOF
    make
    if [ -x ${name}.bin ]; then
cat << EOF
---------------KIT RUN-----------------
EOF
./${name}.bin
cat << EOF
---------------KIT FIN-----------------
EOF
    else
        echo "build binary fail..."
    fi
fi

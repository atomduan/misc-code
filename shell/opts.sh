#!/bin/bash
# a small example program for using the new getopt(1) program.
# this program will only work with bash(1)
# an similar program using the tcsh(1) script. language can be found
# as parse.tcsh
# example input and output (from the bash prompt):
# ./parse.bash -a par1 'another arg' --c-long 'wow!*\?' -cmore -b " very long "
# option a
# option c, no argument
# option c, argument `more'
# option b, argument ` very long '
# remaining arguments:
# --> `par1'
# --> `another arg'
# --> `wow!*\?'
# note that we use `"$@"' to let each command-line parameter expand to a
# separate word. the quotes around `$@' are essential!
# we need temp as the `eval set --' would nuke the return value of getopt.
#-o表示短选项，两个冒号表示该选项有一个可选参数，可选参数必须紧贴选项
#如-carg 而不能是-c arg
#--long表示长选项
#"$@"在上面解释过
# -n:出错时的信息
# -- ：举一个例子比较好理解：
#我们要创建一个名字为 "-f"的目录你会怎么办？
# mkdir -f #不成功，因为-f会被mkdir当作选项来解析，这时就可以使用
# mkdir -- -f 这样-f就不会被作为选项。
temp=`getopt -o ab:c:: --long a-long,b-long:,c-long:: -n 'example.bash' -- "$@"`
echo "temp-->${temp}"
if [ $? != 0 ] ; then echo "terminating..." >&2 ; exit 1 ; fi
# note the quotes around `$temp': they are essential!
#set 会重新排列参数的顺序，也就是改变$1,$2...$n的值，这些值在getopt中重新排列过了
eval set -- "$temp"
echo "temp eval set -->${temp}"
#经过getopt的处理，下面处理具体选项。
while true ; do
        case "$1" in
                -a|--a-long) echo "option a" ; shift ;;
                -b|--b-long) echo "option b, argument \`$2'" ; shift 2 ;;
                -c|--c-long)
                        # c has an optional argument. as we are in quoted mode,
                        # an empty parameter will be generated if its optional
                        # argument is not found.
                        case "$2" in
                                "") echo "option c, no argument"; shift 2 ;;
                                *)  echo "option c, argument \`$2'" ; shift 2 ;;
                        esac ;;
                --) shift ; break ;;
                *) echo "internal error!" ; exit 1 ;;
        esac
done
echo "remaining arguments:"
for arg do
   echo '--> '"\`$arg'" ;
done

#./opts.sh --b-long abc -a -c33 remain

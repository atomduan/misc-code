#!/bin/bash
# ":option_name" no argument value option
# "option_name:" option with argument value
# example: ./cmd -hp abc -f file_foo 
while getopts :help:hp:f: opt ; do
    case "$opt" in
        h|help) echo "help desc" 
            ;;
        p) echo "opt p --> ${OPTARG}"
            ;;
        f) echo "opt f --> ${OPTARG}"
            ;;
    esac
done

echo "NONE_E --> : ${NONE_E:-XXX}"

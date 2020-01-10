#!/bin/bash -x
make clean && make debug
if [ $? -eq 0 ]; then
    (cd build/dist; ./target.bin)
fi

#!/bin/bash -
cp Makefile.mk Makefile
make clean && make all
if [ $? -eq 0 ]; then
(cd build/dist; 
cat << EOF


---------------TARGET RUN-----------------


EOF
    ./target.bin
cat << EOF


---------------TARGET FIN-----------------


EOF
)
fi

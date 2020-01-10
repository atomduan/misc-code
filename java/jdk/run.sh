#!/bin/bash -
make clean && make debug
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

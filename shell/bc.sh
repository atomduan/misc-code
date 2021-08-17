#!/bin/bash -
echo 'obase=16; 1000' | bc | tr [A-Z] [a-z]
echo 'ibase=16; 3e8' | tr [a-z] [A-Z] | sed 's/IBASE/ibase/g' | bc

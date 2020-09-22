#!/bin/bash -
echo 'obase=16; 1000' | bc | tr [A-Z] [a-z]
echo 'ibase=16; 3E8' | bc 

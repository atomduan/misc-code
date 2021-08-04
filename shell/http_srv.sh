#!/bin/bash -
# mock http log
while true; do echo -e $(sleep 1; echo "HTTP/1.1 200 OK\n\n `date`") | nc -l 12345; done

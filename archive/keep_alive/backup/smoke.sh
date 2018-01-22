#!/bin/bash -
curl -v -X POST -d 'phones=13718185947,18210286771&content=test' 'http://10.130.32.21:8080/alarm/sendmessage'

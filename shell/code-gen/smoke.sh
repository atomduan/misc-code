#!/bin/bash -
curl 'http://127.0.0.1:6666/smoke/invoke?param=foo'
echo ""
curl 'http://127.0.0.1:6666/smoke/redis'
echo ""

#!/usr/bin/env bash

httperf \
--server=$1 \
--port=$2 \
--num-conns=$3 \
--uri=/hash \
--client=0/1 \
--send-buffer=4096 \
--recv-buffer=16384 \
--add-header='Content-Type: application/json\nContent-Length: 19\n\n{"password":"test"}' \
--method=POST \
--num-calls=1

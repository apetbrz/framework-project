#!/usr/bin/env bash

httperf \
--server=$1 \
--port=$2 \
--num-conns=$3 \
--uri=/ \
--client=0/1 \
--send-buffer=4096 \
--recv-buffer=16384 \
--method=GET \
--num-calls=1

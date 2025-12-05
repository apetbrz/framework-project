#!/usr/bin/env bash

filename=$1
metric=$2

if [[ $1 = '-h' || $1 = '--help' || $1 = '-?' ]]; then

    echo "
~=[ Arthur's Data Metric Extractor ]=~
    for Spring 2025 Senior Project

Usage:
./getmetric.sh [filename] [metric]

Available Metrics:
latency_avg
latency_max
latency_min
latency_std_deviation
requests_avg
requests_total
transfer_rate
transfer_total
"

    exit

fi

jq -r "{\"metric\":\"$metric\",\"data\":[.tests[] | {\"name\":.name,\"value\":.data.$metric}]}" $filename

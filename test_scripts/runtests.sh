#!/usr/bin/env bash

if [[ $1 = '-h' || $1 = '--help' || $1 = '-?' ]]
then

echo $"
~=[ Arthur's Automated Test System ]=~
    for Spring 2025 Senior Project

Usage:
./runtests.sh [framework target] [conn count] {duration (60s)} {hostname (castelo.lan)}
"

exit

fi

host=$"${4:-"castelo.lan"}:"

axum_port="3000"
dotnet_port="5217"
express_port="3001"
gin_port="8080"

auto_threads=(1 4 16 64 256 1024 2048 4096)
default_duration=5

target=$1
threads=($2)
threads=${threads:-${auto_threads[@]}}
duration=${3:-${default_duration}}

case $target in

  "axum")
    host="${host}${axum_port}"
    ;;
  "dotnet")
    host="${host}${dotnet_port}"
    ;;
  "express")
    host="${host}${express_port}"
    ;;
  "gin")
    host="${host}${gin_port}"
    ;;
  *)
    echo "invalid framework target: $(target)"
    return
    ;;

esac

for threadcount in $threads
do

printf -v formatted_threadcount "%04d" $threadcount

filename="data_${target}_${formatted_threadcount}-conn_$(date "+%Y-%m-%d_%H-%M-%S.json")"

touch $filename

echo "Starting $filename"

hello_starttime="$(date "+%T")"
echo "/hello start: $hello_starttime"
hello_output="$(./awsts.sh $host hello $threadcount $duration --json)"

static_starttime="$(date "+%T")"
echo "/static start: $static_starttime"
static_output="$(./awsts.sh $host static $threadcount $duration --json)"

dynamic_starttime="$(date "+%T")"
echo "/dynamic start: $dynamic_starttime"
dynamic_output="$(./awsts.sh $host dynamic $threadcount $duration 2863311530 --json)"

hash_starttime="$(date "+%T")"
echo "/hash start: $hash_starttime"
hash_output="$(./awsts.sh $host hash $threadcount $duration this_is_a_very_long_password --json)"

jq --null-input \
   --arg testname "${target}_${threadcount}-conn" \
   --arg testdate "$(date "+%d-%m-%Y")" \
   --arg hellotime $hello_starttime \
   --argjson hellodata $hello_output \
   --arg statictime $static_starttime \
   --argjson staticdata $static_output \
   --arg dynamictime $dynamic_starttime \
   --argjson dynamicdata $dynamic_output \
   --arg hashtime $hash_starttime \
   --argjson hashdata $hash_output \
  '{"test":$testname,"date":$testdate,
    "tests":{
     "hello":{"name":"hello","time":$hellotime,"data":$hellodata},
     "static":{"name":"static","time":$statictime,"data":$staticdata},
     "dynamic":{"name":"dynamic","time":$dynamictime,"data":$dynamicdata},
     "hash":{"name":"hash","time":$hashtime,"data":$hashdata}
    }
   }' | tee $filename

done

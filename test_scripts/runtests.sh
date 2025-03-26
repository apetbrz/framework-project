#!/usr/bin/env bash

host=$"${4:-"castelo.lan"}:"

axum_port="3000"
dotnet_port="5217"
express_port="3001"
gin_port="8080"

target=$1
threads=$2
duration=${3:-60}

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


filename=$(date "+%d-%m-%Y_%H-%M-%S_${target}_${threads}-conn_output.log")

touch $filename

echo "Starting $filename"

hello_starttime="$(date "+%T")"
echo "/hello start: $hello_starttime"
hello_output=$(./awsts.sh $host hello $threads $duration --json)

static_starttime="$(date "+%T")"
echo "/static start: $static_starttime"
static_output=$(./awsts.sh $host static $threads $duration --json)

dynamic_starttime="$(date "+%T")"
echo "/dynamic start: $dynamic_starttime"
dynamic_output=$(./awsts.sh $host dynamic $threads $duration 2863311530 --json)

hash_starttime="$(date "+%T")"
echo "/hash start: $hash_starttime"
hash_output=$(./awsts.sh $host hash $threads $duration this_is_a_very_long_password --json)

jq --null-input \
   --arg testname "${target}_${threads}-conn" \
   --arg testdate "$(date "+%d-%m-%Y")" \
  '{"test":$testname,"date":$testdate,
    "tests":{
     "hello":{"time":"'"$hello_starttime"'","data":'"$hello_output"'},
     "static":{"time":"'"$static_starttime"'","data":'"$static_output"'},
     "dynamic":{"time":"'"$dynamic_starttime"'","data":'"$dynamic_output"'},
     "hash":{"time":"'"$hash_starttime"'","data":'"$hash_output"'}
    }
   }' | tee $filename

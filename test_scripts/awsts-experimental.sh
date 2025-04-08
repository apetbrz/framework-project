#!/usr/bin/env bash

if [[ $1 = '-h' || $1 = '--help' || $1 = '-?' ]]
then

echo $"
~=[ Arthur's Web Server Testing Script ]=~
      for Spring 2025 Senior Project

Usage:
./awsts.sh [host ip] [test name] [thread/conn count] [duration (sec)] {testargs} {passed to rewrk}

Tests:  | testargs:
hello   | NONE AVAILABLE
static  | NONE AVAILABLE
dynamic | NONE AVAILABLE
hash    | {Password (default=this_is_a_very_long_password)}
"

else

args=(--pct --connections=${3:-1} --threads=${3:-1} --duration=${4:-10}s --host=http://$1/$2 --header="User-Agent: awsts/0.1.0" --header="Accept: */*" --header="Host: ${1}")

if [[ $2 = 'hash' ]]
then

body=$"{\"password\":\"${5:-"this_is_a_very_long_password"}\"}"
args+=(--method=POST --header="Content-Type: application/json" --header="Content-Length: ${#body}" --body="$body" ${@:6})

else

args+=(${@:5})

fi

rewrk-experimental "${args[@]}"

fi

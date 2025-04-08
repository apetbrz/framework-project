#!/usr/bin/env bash

inputfile=$1
outputfile="$(echo $inputfile | awk -F"/" '{printf "%s/clean_%s", $1, $2}')"
echo $outputfile
cat $1 | grep 'top - \|MiB Mem\|nos' | paste -d' ' - - - | awk -F" " '{printf "%9s | cpu: %4.1f% | cputime: %9s min:sec | mem: %6.1f MiB\n", $3, $32, $34, $20}' | tee $outputfile

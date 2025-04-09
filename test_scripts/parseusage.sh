#!/usr/bin/env bash

inputfile=$1
outputfile="$(echo $inputfile | awk -F"." '{printf "%s.csv", $1}')"
echo $outputfile

cat $1 | grep 'top - \|MiB Mem\|%Cpu' | sed "s/up .*//g" | xargs -d'\n' -n 3 | sed "s/,100/, 100/g" | awk -F" " '{ 
  cpu= 100 - $11
  printf "%s,%f,%f\n", $3, cpu, $28
}' >$outputfile

# top - 18:18:56
# %Cpu(s): 99.0 us,  0.5 sy,  0.0 ni,  0.0 id,  0.0 wa,  0.4 hi,  0.1 si,  0.0 st
# MiB Mem :  32015.1 total,  29224.3 free,   2558.5 used,    606.2 buff/cache

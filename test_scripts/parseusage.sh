#!/usr/bin/env bash

inputfile=$1
outputfile="$(echo $inputfile | awk -F"." '{printf "%s.csv", $1}')"
echo $outputfile

cat $1 | grep 'top - \|MiB Mem\|%Cpu' | xargs -d'\n' -n 3 | sed "s/,100/, 100/g" | awk -F" " '{ 
  cpu= 100 - $20
  printf "%s,%f,%f\n", $3, cpu, $37
}' >$outputfile

# top - 15:05:40 up 1 min,  1 user,  load average: 8.47, 1.91, 0.63
# Tasks: 12 total, 2 running, 10 sleep, 0 d-sleep, 0 stopped, 0 zombie
# %Cpu(s): 78.3 us,  0.8 sy,  0.0 ni, 20.3 id,  0.0 wa,  0.3 hi,  0.3 si,  0.0 st
# MiB Mem :  32015.1 total,  30213.5 free,   1524.7 used,    650.6 buff/cache
# MiB Swap:      0.0 total,      0.0 free,      0.0 used.  30490.3 avail Mem

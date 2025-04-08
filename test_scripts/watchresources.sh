filename="usage_${1}_$(date "+%Y-%m-%d_%H-%M-%S").log"
touch "freshdata/$filename"
top -b -d 10 -n 200 -p $(pgrep -d ',' ^$1) | tee -a "$filename"

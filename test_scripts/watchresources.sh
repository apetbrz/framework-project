if [[ $1 = '-h' || $1 = '--help' || $1 = '-?' || $1 = '' ]]; then

    echo $"Use this script before each framework test.
usage:
    ./watchresources.sh [framework target name]"
    exit
fi
filename="usage_${1}_$(date "+%Y-%m-%d_%H-%M-%S").log"
touch "freshdata/$filename"
top -b -d 10 -n 200 -p $(pgrep -d',' "$1") | tee -a "$filename"

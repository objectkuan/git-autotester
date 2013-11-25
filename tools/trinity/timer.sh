img_used=$1
time_run=$2
sleep $time_run
pidtokill=`ps x | grep qemu | grep "$img_used"|awk '{print $1}'`
echo "qemu pid to kill:$pidtokill"
kill -9 $pidtokill

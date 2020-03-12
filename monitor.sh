#!/bin/bash
if [ $# -ne "2" ]; then
  # TODO: print usage
  echo "Enter 2 args"
  exit 1
fi
percent=$(df -h | grep -w "/"|rev|cut -d ' ' -f2|rev | sed 's/\%//g')
size=$(df -h |grep -w "/"|rev|cut -d ' ' -f8|rev| sed 's/\G//g')
#size=${size%.*}
size=`printf '%.*f\n' 0 "$size"`


limit=20
if [ "$percent" -gt "$limit" ]
  then
        echo "you are runing out of memory"
instanceid=`wget -q -O - http://<ip>/latest/meta-data/instance-id`
volumeid=`aws ec2 describe-volumes --filters Name=attachment.instance-id,Values="$instanceid" --region ap-south-1| tail -6 | head -n1 | cut -d':' -f2 | sed 's/\"//g'|sed 's/\,//g'| sed 's/\ //g'`
if [ "$2" = "Y" ] ; then
increasesize=$1
sum=$(($size + $increasesize))
echo "total size is $sum "
aws ec2 modify-volume --region ap-south-1 --volume-id "$volumeid" --size "$sum" --volume-type gp2
if [ "$?" == "254" ] ; then
datte=`date +%D:%T`
exit 1
else :
datte=`date +%D:%T`
sleep 30 ; sudo growpart /dev/xvda 1 ; sleep 2 ;sudo resize2fs /dev/xvda1
fi
elif [ "$2" = "N" ] ; then
echo "No Selected"
fi
else
echo "No need of increasing disk"
fi
~ 

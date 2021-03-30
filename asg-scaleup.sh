#!/bin/bash
###############################################################
#### Add all the env names that needs to be disposed ##########
ENV_ARRAY=($1)
###############################################################
#rundeck_bot aws credentials
export AWS_ACCESS_KEY_ID=<xyz>
export AWS_SECRET_ACCESS_KEY=<xyz>
REGION=us-east-1
declare -a ASG_ARRAY
#set -o xtrace
ASG_LIST=`aws autoscaling describe-auto-scaling-groups --region $REGION --query AutoScalingGroups[*].AutoScalingGroupName --output text`
ASG_ARRAY=($ASG_LIST)
for env_name in "${ENV_ARRAY[@]}"
do
  for asg in "${ASG_ARRAY[@]}"
  do
      if [[ $asg == *"-$env_name-all"* ]] || [[ $asg == *"-$env_name-mongodb"* ]]; then
        echo "*********************************************************"
        echo "ScalingUp ASG $asg"
        ASG_MAX_SIZE=`aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $asg --region  $REGION --query AutoScalingGroups[*].MaxSize --output text`
        echo "$asg | Setting desired-capacity = $ASG_MAX_SIZE"
        aws autoscaling update-auto-scaling-group --region $REGION --auto-scaling-group-name $asg --desired-capacity $ASG_MAX_SIZE
      fi
  done
done



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
ASG_LIST=`aws autoscaling describe-auto-scaling-groups --region $REGION --query AutoScalingGroups[*].AutoScalingGroupName --output text`
ASG_ARRAY=($ASG_LIST)
#set -o xtrace
for env_name in "${ENV_ARRAY[@]}"
do
  for asg in "${ASG_ARRAY[@]}"
  do
    if [[ $asg == *"-$env_name-all"* ]] || [[ $asg == *"-$env_name-mongodb"* ]]; then
        dispose_value=`aws autoscaling describe-tags --region $REGION --filters Name=auto-scaling-group,Values=$asg Name=Key,Values=dispose --query Tags[*].[Value] `
        if [[ $dispose_value == *"true"* ]]; then
          echo "disposing ASG $asg"
          echo "$asg | Setting desired-capacity = 0"
          aws autoscaling update-auto-scaling-group --region $REGION --auto-scaling-group-name $asg --min-size 0 --desired-capacity 0
        else
          echo "Not disposing ASG $asg because dispose tag value is false"
        fi
        echo "tagging dispose as true for next run in $asg"
        aws autoscaling create-or-update-tags --region $REGION --tag ResourceId=$asg,ResourceType=auto-scaling-group,Key="dispose",Value="true",PropagateAtLaunch=false
        echo "*************************************"
    fi
  done
done

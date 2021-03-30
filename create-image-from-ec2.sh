#!/bin/bash
set -o xtrace
instance_name="<name of ec2 instance>"
#rundeck_bot aws credentials
export AWS_ACCESS_KEY_ID=<xyz>
export AWS_SECRET_ACCESS_KEY=<xyz>
REGION="<xyz>"

instanceId=`aws ec2 describe-tags --filters "Name=resource-type,Values=instance" "Name=key,Values=Name" "Name=value,Values=$instance_name" --region $REGION --query Tags[].ResourceId --output text`
amiName=$instance_name-$(date +%Y/%m/%d-%H-%M)
echo "instance id "$instanceId
AMIID=`aws ec2 create-image --instance-id $instanceId --name "$amiName-" --description "ami of $name" --region $REGION --no-reboot | head -n2 | tail -n1 | cut -d'"' -f4`

echo "${name}'s: AMI taken using InstanceId $instanceId. AMI-ID is $AMIID"$name

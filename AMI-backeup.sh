#bin/bash

DATE=$(date +%Y-%m-%d_%H-%M) 
AMI_NAME="<service-name>-$DATE"
AMI_DESCRIPTION="Backup of <service-name> dated - $DATE"
INSTANCE_ID=<instance-id>

printf "Requesting AMI for instance $INSTANCE_ID...\n"
aws ec2 create-image --instance-id $INSTANCE_ID --name "$AMI_NAME" --description "$AMI_DESCRIPTION" --region <region> --no-reboot


#!/bin/bash
OWNER=<accountID>
export AWS_ACCESS_KEY_ID=xyz
export AWS_SECRET_ACCESS_KEY=xyz
REGION=xyz
d=$(date --date='5 days ago' +%Y-%m-%d)
echo "$d"
aws ec2 describe-images --filters "Name=name,Values=<amiName>" --query 'Images[?CreationDate<=`'$d'`][]' --owner $OWNER --region $REGION| grep -i "ImageId" | cut -d ':' -f2 | cut -d '"' -f2 > ami.txt 
cat ami.txt 
for id in `cat ami.txt`
do
	snapshotId=$(aws ec2 describe-images --filters "Name=image-id,Values=$id" --region $REGION| grep -i "SnapshotId" | cut -d ':' -f2 | cut -d '"' -f2)
	aws ec2 deregister-image --image-id $id --region $REGION
	echo "snapshot"
	echo "$id"
	aws ec2 delete-snapshot --snapshot-id $snapshotId --region $REGION
	echo "Snapshot deleted: "$snapshotId
done

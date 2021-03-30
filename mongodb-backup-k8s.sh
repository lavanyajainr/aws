#!/bin/bash
set -o xtrace 
#aws eks --region us-east-1 update-kubeconfig --name <cluster-name>
NAMESPACE="prod"
export MONGODB_ROOT_PASSWORD=$(kubectl get secret --namespace $NAMESPACE mongodb -o jsonpath="{.data.mongodb-root-password}" | base64 --decode)
kubectl port-forward --namespace $NAMESPACE svc/mongodb-headless 27017:27017 &

TIMESTAMP=`date +%F-%H%M`
FILE_NAME="/tmp/$NAMESPACE/mongodb_$TIMESTAMP"
sudo mkdir -p $FILE_NAME
sudo chmod 777 $FILE_NAME
cd $FILE_NAME

sudo docker run --rm --name mongodb -v $FILE_NAME:/app --net="host" bitnami/mongodb:latest mongodump -u root -p $MONGODB_ROOT_PASSWORD -o /app

PID=$(lsof -nPi:27017 | grep IPv4 | cut -d' ' -f 2)
kill -9 $PID

BACKUP_NAME="mongodb_$TIMESTAMP"

sudo tar -zcvf /tmp/$NAMESPACE/$BACKUP_NAME.tgz $FILE_NAME

#rundeck_bot aws credentials
export AWS_ACCESS_KEY_ID=<xyz>
export AWS_SECRET_ACCESS_KEY=<xyz>
REGION=<xyz>


aws s3 cp /tmp/$NAMESPACE/$BACKUP_NAME.tgz s3://<s3-name>/backup/$NAMESPACE/mongodb/

sudo rm -rf $FILE_NAME

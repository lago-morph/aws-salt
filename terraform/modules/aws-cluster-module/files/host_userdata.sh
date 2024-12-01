#!/bin/bash
# Set up region for aws command line
apt-get install jq -y
REGION=`curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq .region -r`
aws configure set region $REGION
## grab the values we need from tags and SSM parameter
CLUSTER_NAME=$(curl http://169.254.169.254/latest/meta-data/tags/instance/cluster_name)
echo "nameserver 10.0.0.2" >> /etc/resolv.conf
echo "search $CLUSTER_NAME.cluster" >> /etc/resolv.conf

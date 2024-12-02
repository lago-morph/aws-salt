#!/bin/bash
# Set up region for aws command line
apt-get install jq -y
REGION=`curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq .region -r`
aws configure set region $REGION
## grab the values we need from tags and SSM parameter
CLUSTER_NAME=$(curl http://169.254.169.254/latest/meta-data/tags/instance/cluster_name)
echo "nameserver 10.0.0.2" >> /etc/resolv.conf
echo "search $CLUSTER_NAME.cluster" >> /etc/resolv.conf
HOST_NAME=$(curl http://169.254.169.254/latest/meta-data/tags/instance/Name)
echo "$HOST_NAME" > /etc/salt/minion_id
echo "$HOST_NAME" > /hostname
hostname $HOST_NAME
systemctl restart salt-minion
RES_CONF=/etc/systemd/resolved.conf
echo "[Resolve]" > $RES_CONF
echo "DNS=10.0.0.2" >> $RES_CONF
echo "Domains=$CLUSTER_NAME.cluster" >> $RES_CONF
systemctl restart systemd-resolved


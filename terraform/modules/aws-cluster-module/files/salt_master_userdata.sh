#!/bin/bash
# Set up region for aws command line
apt-get install jq -y
REGION=`curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq .region -r`
aws configure set region $REGION
## grab the values we need from tags and SSM parameter
CLUSTER_TYPE=$(curl http://169.254.169.254/latest/meta-data/tags/instance/cluster_type)
REPOSITORY_SOURCE=$(curl http://169.254.169.254/latest/meta-data/tags/instance/repository_source)
CLUSTER_NAME=$(curl http://169.254.169.254/latest/meta-data/tags/instance/cluster_name)
SSM_SECRET_PATH=$(curl http://169.254.169.254/latest/meta-data/tags/instance/ssm_secret_path)
BRANCH=$(curl http://169.254.169.254/latest/meta-data/tags/instance/branch)
PRIVATE_KEY=$(aws ssm get-parameter --with-decryption --name $SSM_SECRET_PATH | jq -r .Parameter.Value)
## put back newlines where needed and set up private key for repository
PKFILE=/tmp/repokey
echo "nameserver 10.0.0.2" >> /etc/resolv.conf
echo "search $CLUSTER_NAME.cluster" >> /etc/resolv.conf
echo $PRIVATE_KEY | sed "s/- /-\n/" | sed "s/ -/\n-/" > $PKFILE
chmod 600 $PKFILE
## Clone the repository
REPOSITORY=gitrepo
GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new -i $PKFILE" git clone $REPOSITORY_SOURCE /opt/$REPOSITORY
## move repository to /opt and set up symbolic links
cd /opt/$REPOSITORY
git checkout $BRANCH
ln -s /opt/$REPOSITORY/salt /srv/salt
ln -s /opt/$REPOSITORY/pillar /srv/pillar
ln -s /opt/$REPOSITORY/salt/master.d/* /etc/salt/master.d/
## start stuff
systemctl restart salt-master

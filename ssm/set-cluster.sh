#!/bin/bash
#

CLUSTER_TYPE="simple-cluster-type"
CLUSTER_NAME="simple-cluster-name"
HOSTCLASS1="load-balancer"
HOSTCLASS2="webserver"

aws ssm put-parameter \
    --name "/cluster/$CLUSTER_NAME/cluster-type" \
    --value "$CLUSTER_TYPE" \
    --type String 

aws ssm put-parameter \
    --name "/cluster/$CLUSTER_NAME/host-number/$HOSTCLASS1" \
    --value "1" \
    --type String 

aws ssm put-parameter \
    --name "/cluster/$CLUSTER_NAME/public-ip/$HOSTCLASS1" \
    --value "true" \
    --type String 

aws ssm put-parameter \
    --name "/cluster/$CLUSTER_NAME/host-number/$HOSTCLASS2" \
    --value "2" \
    --type String 

aws ssm put-parameter \
    --name "/cluster/$CLUSTER_NAME/public-ip/$HOSTCLASS2" \
    --value "false" \
    --type String 


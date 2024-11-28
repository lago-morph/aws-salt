#!/bin/bash

TYPE_REPO="simple_type"
CLUSTER_TYPE="simple_cluster_type"
BRANCH="main"

aws ssm put-parameter \
    --overwrite \
    --name "/cluster_type/$CLUSTER_TYPE/type_repo" \
    --value "$TYPE_REPO" \
    --type String 

aws ssm put-parameter \
    --name "/cluster_type/$CLUSTER_TYPE/branch" \
    --value "$BRANCH" \
    --type String 

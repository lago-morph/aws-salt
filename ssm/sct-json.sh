#!/bin/bash

aws ssm put-parameter \
    --overwrite \
    --name "/cluster/simple-cluster-name" \
    --value "$(cat simple-cluster-name.json)" \
    --type String 

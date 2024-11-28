#!/bin/bash
#
# I should change this to take a filename on the command line which then goes 
# and reads in the key and key.pub files.  That way you can keep them outside 
# of the repository structure and don't risk putting them in the git repo.

TYPE_REPO="simple_type"
REPO_ORGANIZATION="lago_morph"
REPO_REPOSITORY="aws_salt_simple"

# Key should be a read-only deploy key for just this repository
REPO_PUBLIC_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBmBgR6XruV0ny8XNQ2HWVXfB35UNn+wFaNa96XmH56L Read-only Key for aws-salt-simple "

# private key must be added separately - instructions in output

aws ssm put-parameter \
    --name "/cluster_repo/$TYPE_REPO/organization" \
    --value "$REPO_ORGANIZATION" \
    --type String 

aws ssm put-parameter \
    --name "/cluster_repo/$TYPE_REPO/repository" \
    --value "$REPO_REPOSITORY" \
    --type String 

aws ssm put-parameter \
    --name "/cluster_repo/$TYPE_REPO/public_key" \
    --value "$REPO_PUBLIC_KEY" \
    --type String 

echo "Set the private key manually using the following command:"
echo -e "aws ssm put-parameter --name \"/cluster_repo/$TYPE_REPO/private_key\" --type \"SecureString\" --value \"\`cat ~/secrets/aws-salt-simple\`\""



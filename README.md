# Overview
What I want to do here is come up with a way to leverage packer, terraform, and salt to built infrastructure on AWS in a professional and robust way.

# Repositories
There is one repo, aws-salt, that contains the terraform module and helper scripts (e.g., packer build).

There is an ultimate upstream repository [cluster-type-template](https://github.com/lago-morph/cluster-type-template) from which cluster-type repositories should fork.

For each cluster-type, there is one upstream repository forked from repo cluster-type-template, which targets the region you are doing development in for that type of cluster.  For additional regions, you will fork the cluster-type repo.

## Repository diagram

aws-salt

cluster-type-template
   ||
 (fork)
   \/
cluster-redis-default == (fork) ==> cluster-type-redis-us-east-2
   ||
(branch)
   \/
cluster-redis branch-n

So a "cluster" is a cluster-type repository (potentially forked with the
region redefined), plus a branch of that repository.  There cannot be multiple
clusters with different names with the same repo and branch.  Just create a
new branch in the git repository if you want another cluster with an identical configuration.

The cluster name is (cluster-type)-(branch-name), and must be unique by region
and account.

For convenience we will store the terraform state in the git repository with each cluster-repo and branch.  This can be easily overridden if you want remote state, e.g. in an S3 bucket.

# Instantiation instructions
For example, say I'm interested in making a redis cluster.  Here are the sequence of steps I would follow:
1. Fork [cluster-type-template](https://github.com/lago-morph/cluster-type-template) to a new repository called `cluster-redis-default`.
2. Create a new ssh key pair or use an existing one for access to the `cluster-redis-default` git repo.  For instance, on GitHub you would add the public key as a "deploy key" for the repository.
3. Clone your new repository to your local system.
4. Clone [aws-salt](https://github.com/lago-morph/aws-salt) to your local system.
5. Configure your AWS CLI to access your account and the region in which you plan to deploy the cluster.
6. cd `aws-salt/packer`, and type `packer init .` followed by `packer build .` to build the AMIs.  This takes 10-15 minutes, so do it early so you can do the rest of the setup while waiting.
7. In the file `cluster-redis-default/cluster-type.json`, set "cluster_type" to redis, "repository_source" to the ssh-accessible URL for the `cluster-redis-default` repository, then set your region and a reference to the private key file on your local machine that can access the repo read-only (e.g., GitHub deploy key or equivalent).
8. In the file `cluster-redis-default/cluster.json` file, create records for each type of host you want in the cluster, the number to create, and if it should be on the public IP subnet of the VPC (otherwise it will be on a private subnet with no route to the internet).  Note that a NAT gateway is not currently created for the private subnets (this is a future todo).
9. Add the ssh private key from step 1a in the AWS SSM paramter `/<type>-<branch>/private_key`.  E.g., for cluster type `redis`, instantiated from branch `main`, you need to populate the SSM parameter `/redis-main/private_key`.  There is a script in `cluster-type-template/scripts/set-private-key.sh` that will set this parameter if the private key file is on your local filesystem, and you've configured the location in `cluster-type.json`.  You can also populate this parameter using the AWS web console or AWS CLI.
10. change directory to `cluster-redis-default/terraform`, and type `make init` followed by `make apply-auto-approve` to build your cluster.  This will create a cluster with name `redis-master` or `redis-main`, depending on your default branch name.
11. Make sure to commit the `cluster-redis-default/terraform/terraform.tfstate` file into your git repository.  This is the Terraform state file and needs to be saved as long as your cluster is running.
12. Once the cluster has been created, you can ssh to the salt-master by being in the directory `cluster-redis-default/terraform` and typing `make ssh-master`.
13. You can create other clusters in different branches with different configurations by creating a new git branch, changing cluster.json, deleting terraform.tfstate (make sure it is committed in its branch before deleting), and following along again from step 8.

To instantiate a cluster in another region (e.g., `us-east-2`), fork `cluster-redis-default` to another repo named `cluster-redis-us-east-2`.  Clone this repo, change the region and repository_source in cluster-type.json, check out the branch in the repo you want to build the cluster for, delete terraform.tfstate, configure AWS CLI to use us-east-2, and follow along from step 8 above.  The naming standard to use `default` as the region name for the first repo is just so it is easier to see which one is the upstream for the other ones, so you can make changes there that need to propagate to the other regions.


So:
1x system repo: aws-salt
1x template repo: cluster-type-template
for each distinct cluster type:
1x cluster-<type>-default repo forked from cluster-type-template with definition of saltstate and saltclass
Mx repos for clusters of the same type, but in different regions (`cluster-<type>-<region>`)
Nx branches per cluster-type and region, one for each distinct cluster

# Configuration files
Repo cluster-type-template has (in root of repo)
```
cluster-type.json
{ "cluster_type": <cluster-type-name>,  (e.g., "redis") (override when forking template)
  "repository_source": <whatever.git>, (e.g., "git@github.com:lago-morph/cluster-type-template.git")
  "region" : <region>, (e.g., us-east-1) (overwrite when forking cluster-<type>-default)
  "private_key_file" : <filename> (e.g., ~/secrets/default-ro-key)
}
```
Make sure repository_source matches the name of the new repository or you will
be sad (this is not checked!)

Don't store private_key_file in repository directory structure!

cluster.json (potentially different for each branch)
```
{ 
  "hostclass": 
    [
       {
         "class_name": <saltclass1>,
	     "num_hosts": <num>,
	     "public_ip": <true/false>
       },
       {
         "class_name": <saltclass2>,
	     ...
       },
       ...
    ]
}
```

# More instructions
This needs to be cleaned up as it duplicates the stuff above.

0. Ensure the base images have been created
(This step only needs to be done once per account/region combination)

- Clone the repository `aws-simple`.  
- Configure the AWS CLI.  
- Change directory to `aws-simple/packer`.
- Run `packer init .` followed by `packer build .` (This takes 10-15 minutes typically, and can run in the background while doing the rest of this stuff)

If you need to build just one of the AMIs (minion or master):
- `packer build -only=minion-build.amazon-ebs.ubuntu-20-04-amd64 .`
- `packer build -only=master-build.amazon-ebs.ubuntu-20-04-amd64 .`

1. Create the cluster-type repository.

Fork your new cluster-type repository from `cluster-type-template`.  Name the
new repository `cluster-<type>-default`, where `<type>` is a descriptive name
(referred to as `cluster_type` below) like `redis` or something to describe 
this type of cluster.

Add the public key for a ssh keypair as a deploy-key in cluster-<type>-default.

Clone the new repo to your local filesystem.

In cluster-type.json, make sure you fill out the cluster-type-name, region,
and provide a filename on the local filesystem which contains the private key
for the deploy key.  In the future this may be replaced with something using
Vault, this is a workaround for now.

2. Upload private key to AWS.

Using scripts/aws_ssm_key.sh, copy the private deploy key to the 
System Manager Parameter Store on your AWS account.

3. Create a cluster using the cluster.json.  
If desired, change cluster.json to meet needs.  If desired, create a branch.

go to the terraform directory, and in succession type
make init (only required when the first time)
make plan (if you want to see what it will do)
make apply or make apply-auto-approve

If done with the Makefile, it will validate the region you are configured to
use, the region specified in cluster-type.json, and the region from the state
file (for an already-created cluster) are consistent.

When a cluster is created it uses the cluster_type_name and the branch to
create a cluster instance.  Cluster instances can be ephemeral, or could
correspond to long-lived functions like prod or staging.  aws-salt does not
use the Salt environment feature, and I try not to use that term to avoid
confusion.

Be careful about merging
branches that each have a cluster associated with them - the terraform state
for the cluster is stored in Git, and you don't want to accidentally overwrite
an active cluster state file with a merge.

It may take a while for the cluster to build.  

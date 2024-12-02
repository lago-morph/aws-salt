What I want to do here is come up with a way to leverage packer, terraform,
and salt to built infrastructure on AWS in a professional and robust way.

This is a "GitOps" driven cluster system.

There is one repo, aws-salt, that contains the terraform module and helper
scripts (e.g., packer build).

There is an ultimate upstream repository cluster-type-template from which 
cluster-type repositories should fork.

For each cluster-type, there is one upstream repository forked from
repo cluster-template, which targets the
region you are doing development in for that type of cluster.  For additional
regions, you will fork the cluster-type repo.

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
new branch if you want another cluster with an identical configuration.

The cluster name is (cluster-type)-(branch-name), and must be unique by region
and account.

For convenience we will store the terraform state in with each cluster-repo
and branch.

In this example, Only actively modify the repository 
cluster-type-redis-repo, maybe with branches main (production), staging, and
however many dev branches are needed.
branches to represent cluster types.

I have not adapted the cardinality of trying to do this with multiple
accounts.  I'm open to contributions adding that without make a default
one-account system more complex.

So:
1 system repo: aws-salt
1 template repo: cluster-type-template
for each distinct cluster type:
1 cluster-<type>-default repo forked from cluster-type-template with definition of saltstate and saltclass
n branches, one for each distinct cluster in the default region

For each m <region> other than the default region deploying cluster type <type>:
m forks of cluster-<type>-default: cluster-<type>-<region>
(it is intended for the region definition to change in these forks, along with
perhaps the numbers of host classes in the various clusters)

Repo cluster-type-template has (in root of repo)
cluster-type.json
{ "cluster_type": <cluster-type-name>,  (e.g., "redis") (override when forking template)
  "repository_source": <whatever.git>, (e.g., "git@github.com:lago-morph/cluster-type-template.git")
  "region" : <region>, (e.g., us-east-1) (overwrite when forking cluster-<type>-default)
  "private_key_file" : <filename> (e.g., ~/secrets/default-ro-key)
}
Make sure repository_source matches the name of the new repository or you will
be sad (this is not checked!)
Don't store private_key_file in repository directory structure!

cluster.json (potentially different for each branch)
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

===============================================================================
2024-11-29-2 Process design

0. Ensure the base images have been created
(This step only needs to be done once per account/region combination)

Clone the repository aws-simple.  
Configure the AWS CLI.  
Change directory to aws-simple/packer.
Run `packer init .` followed by `packer build .`
  (This takes 10-15 minutes typically, and can run in the background while
  doing the rest of this stuff)
Sometimes one or another of the builds fail.  You can do just one with one of
packer build -only=minion-build.amazon-ebs.ubuntu-20-04-amd64 .
packer build -only=master-build.amazon-ebs.ubuntu-20-04-amd64 .

1. Create the cluster-type repository.

Fork your new cluster-type repository from cluster-type-template.  Name the
new repository "cluster-<type>-default", where <type> is a descriptive name
(referred to as cluster_type_name below) like "redis" or something to describe 
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

4. Access your cluster
If you defined an ssh-bastion, then you can (from the terraform directory) do
make ssh-cluster

It may take a while for the cluster to build.  

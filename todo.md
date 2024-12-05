# Highest priority (bugs or major flaws)
- [ ] diagnose DNS issue on startup
  - This just seems to "go away" if I wait 5 minutes.  I'm confuzzled.
- [X] Switch to S3 state backend to remove issue with git merging overwriting terraform state (though this just leads to overwriting the backend.tf file...)
  - could not use solution with .gitattributes and custom merge target (see changelog)
  - Changed makefile to use a terraform workspace named after the branch whenever manipulating state
- [X] Provide option to build a NAT gateway (otherwise software installs and updates won't work for hosts on private subnets).
- [X] Modify security group so that only cluster members can request to be minions to salt-master
- [X] pass back out vpc, subnets, whatever is needed to use vpc after cluster created
- [ ] Verify ability to fork template repo, then pull down updates later

# High priority (medium flaws or unimplemented basic features)
- [X] Update README.md to include steps to generate node list, see the master top data, and apply state
- [ ] Implement ability to taint hosts in Makefile

# Medium priority (needed for someone else to want use)
- [ ] automatic script to wait for key requests and then approve them then to build the node files after salt-master boots (e.g., automated init of salt-master)
- [ ] Timed cron job to apply state to minions periodically (every hour?)
- [ ] Option to pass in already-created VPC to use rather than always creating a new one per cluster
- [ ] Implement single web server "pattern" with source for website content (S3 bucket?  set in SSM parameter maybe?)
- [ ] Allow setting default instance type (salt-master and default for hosts)
- [ ] Allow overriding default instance type per host class
- [ ] Publish terraform module and change reference from template to the terraform module registry
- [ ] Clean up README.md to remove duplicate instructions, add instructions for how to instantiate a webserver with the default-type-template repo.
- [ ] Implement bastion host and associated basic firewall rules (hosts accept ssh only from bastion on inside, bastion only host accessable via ssh from outside)

# Low priority
- [ ] Implement load balancer/web-server "pattern"
  - use class inheritance to make some webservers have different pages or something
- [ ] Implement compute cluster (MPI) pattern
- [ ] Add ability to create additional users as part of cluster creation
- [ ] Implement rules for firewall (e.g., host that wants open ports has to declare it in the class file)
- [ ] Fix mermaid diagram in README.md so it has better layout

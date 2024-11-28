define DOCS
Convenience helpers for Watch and Chill IaC

backend-init    Create S3 bucket, DynamoDB table, and output to backend.tf
                (this is completely optional)

ssh-salt-master
SSH to particular host

tunnel-monitor	Set up ssh tunnel mapping 192.168.88.130:8000 to localhost:80

apply			runs terraform apply --auto-approve

endef


MAKEFLAGS += --jobs

SM = $(shell terraform output -raw salt_master_public_ip)

.ONESHELL:

# dummy target does nothing when make without arguments
export DOCS
show-usage: 
	@echo "$$DOCS"

apply:
	terraform apply --auto-approve

ssh:
	ssh  -A -o "StrictHostKeyChecking no" ubuntu@$(HOST_IP)

ssh-salt-master: HOST_IP = $(SM)
ssh-salt-master: ssh


create-resources:
	aws s3 mb s3://$(S3B)
	aws dynamodb create-table \
		  --table-name $(DDBNAME) \
		  --key-schema AttributeName=$(DDBKEY),KeyType=HASH \
		  --attribute-definitions AttributeName=$(DDBKEY),AttributeType=S \
		  --billing-mode PAY_PER_REQUEST \
		  --no-cli-pager

output-file:
	cat <<EOF > $(TFBACKENDFILE)
	terraform {
	  backend "s3" {
	    bucket                 = "$(S3B)"
	    region                 = "$(REGION)"
	    key                    = "backend.tfstate"
	    dynamodb_table         = "$(DDBNAME)"
	  }
	}
	EOF

backend-init: S3B := chiller-state-bucket-$(shell openssl rand -hex 10)
backend-init: DDBNAME = terraformstatelock
backend-init: DDBKEY = LockID
backend-init: REGION = $(shell aws configure get region)
backend-init: TFBACKENDFILE := backend.tf

backend-init: create-resources output-file
	terraform fmt

tunnel-monitor:
	ssh  -L 192.168.88.130:8000:127.0.0.1:80 ubuntu@$(SM)

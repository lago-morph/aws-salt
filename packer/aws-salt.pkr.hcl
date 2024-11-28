packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_prefix" {
  type    = string
  default = "aws-salt/images"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu-20-04-amd64" {
  instance_type = "t3.medium"
  region        = "us-east-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name    = "minion-build"
  sources = ["source.amazon-ebs.ubuntu-20-04-amd64"]
  source "amazon-ebs.ubuntu-20-04-amd64" {
    ami_name = "${var.ami_prefix}/salt-minion/${local.timestamp}"
  }

  provisioner "shell" {
    script = "scripts/install-salt-minion.sh"
  }
  tags = [
    "name" = "salt-minion"
  ]
}

build {
  name    = "master-build"
  sources = ["source.amazon-ebs.ubuntu-20-04-amd64"]
  source "amazon-ebs.ubuntu-20-04-amd64" {
    ami_name = "${var.ami_prefix}/salt-master/${local.timestamp}"
  }

  provisioner "shell" {
    scripts = [
      "scripts/install-salt-minion.sh",
      "scripts/install-salt-master.sh",
      "scripts/install-gh.sh"
    ]
  }

  tags = [
    "name" = "salt-master"
  ]
    
}


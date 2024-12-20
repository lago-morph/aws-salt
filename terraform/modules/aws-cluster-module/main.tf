data "aws_ami" "salt_master" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "tag:name"
    values = ["salt_master"]
  }
}

data "aws_ami" "salt_minion" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "tag:name"
    values = ["salt_minion"]
  }
}

locals {
  cluster_instances = merge([for hc in var.hostclass :
    { for i in range(hc.num_hosts) :
      "${hc.class_name}-${i}" => {
        class_name = hc.class_name
        public_ip  = hc.public_ip
      }
  }]...)
  # The dots invoke "grouping mode" in the for loop.  Strange syntax.
  # https://stackoverflow.com/questions/71250499/nested-loops-and-looping-over-maps-in-terraform
}

resource "aws_instance" "salt_master" {

  ami                         = data.aws_ami.salt_master.id
  instance_type               = var.instance_type
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [module.ssh_sg.security_group_id]
  key_name                    = aws_key_pair.jonathan.key_name
  iam_instance_profile        = aws_iam_instance_profile.salt_master.name
  private_dns_name_options {
    hostname_type = "resource-name"
  }

  metadata_options {
    instance_metadata_tags = "enabled"
  }

  user_data = file("${path.module}/files/salt_master_userdata.sh")

  tags = {
    Name              = "salt-master"
    host_class        = "salt-master"
    cluster_name      = var.cluster_name
    cluster_type      = var.cluster_type
    repository_source = var.repository_source
    ssm_secret_path   = "/${var.cluster_name}/private_key"
    branch            = var.branch
  }
}

resource "aws_instance" "host" {
  for_each = tomap(local.cluster_instances)

  ami                         = data.aws_ami.salt_minion.id
  instance_type               = var.instance_type
  subnet_id                   = each.value["public_ip"] ? module.vpc.public_subnets[0] : module.vpc.private_subnets[0]
  associate_public_ip_address = each.value["public_ip"]
  vpc_security_group_ids      = [module.ssh_sg.security_group_id]
  key_name                    = aws_key_pair.jonathan.key_name
  private_dns_name_options {
    hostname_type = "resource-name"
  }

  metadata_options {
    instance_metadata_tags = "enabled"
  }

  user_data = file("${path.module}/files/host_userdata.sh")

  tags = {
    Name         = each.key
    host_class   = each.value["class_name"]
    cluster_name = var.cluster_name
    cluster_type = var.cluster_type
  }
}


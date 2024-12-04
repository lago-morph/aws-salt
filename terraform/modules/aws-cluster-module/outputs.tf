output "salt_master_public_ip" {
  value = aws_instance.salt_master.public_ip
}

output "salt_master" {
  value = aws_instance.salt_master
}

output "host" {
  value = aws_instance.host
}

output "hostmap" {
  value = tomap(local.cluster_instances)
}

locals {
  public_ips = { for hostname, v in tomap(local.cluster_instances) : "${hostname}" => aws_instance.host[hostname].public_ip }
}
output "public_ips" {
  value = local.public_ips
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet" {
  value = module.vpc.private_subnets[0]
}

output "public_subnet" {
  value = module.vpc.public_subnets[0]
}


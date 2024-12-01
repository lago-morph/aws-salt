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
  public_ip = { for hostname, v in tomap(local.cluster_instances) : "${hostname}" => aws_instance.host[hostname].public_ip }
}
output "public_ip" {
  value = local.public_ip
}

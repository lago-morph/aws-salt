/*
output "c-i" {
  value = local.c-i
}
*/

output "cluster-instances" {
  value = local.cluster-instances
}

output "cluster-name" {
  value = var.cluster-name
}

output "admin-users" {
  value = var.admin-users
}

output "cluster-data" {
  value = var.cluster-data
}

output "cluster-type" {
  value = var.cluster-data.cluster-type
}

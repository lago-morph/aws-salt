output "salt_master_public_ip" {
  value = aws_instance.salt_master.public_ip
}

output "salt_master" {
  value = aws_instance.salt_master
}

output "host" {
  value = aws_instance.host
}

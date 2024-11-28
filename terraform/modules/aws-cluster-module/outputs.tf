output "salt_master_public_ip" {
  value = aws_instance.salt_master.public_ip
}

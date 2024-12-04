resource "aws_key_pair" "jonathan" {
  key_name   = "jonathan-ssh-key_{$var.cluster_name}"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPgZjXGUu7XcELfdCBpzuN56s6+eJUmqGTKcMlN0zZWN jonathan@manton.com"
}

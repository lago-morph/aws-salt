locals {
  ssm_secret_path = "/${var.cluster_name}/private_key"
}

resource "aws_ssm_parameter" "private_key" {
  name        = local.ssm_secret_path
  description = "secret key for repository access"
  type        = "SecureString"
  value       = var.private_key
}

# create a role that allows the salt-master to access the relevant 
# sections of the parameter store

# We have to do several things to get permissions set up.
# We need an IAM policy document for accessing the parameters
# We need the *text* for a policy document to allow EC2 to assume the role
# We need a role with the assume_role
# We need a policy attachment to attach the ssm permissions document to the role
# We need an instance profile that encapsulates the role
# we need to give the instance profile to the instance when it is launched

/*
# figure out what the type_repo is for the cluster_type we are using
data "aws_ssm_parameter" "type_repo" {
  name = "/cluster_type/${local.cluster_type}/type_repo"
}
*/

/*
locals {
  cluster_type = var.cluster_type
}
locals {
  type_repo = data.aws_ssm_parameter.type_repo.insecure_value
}
*/

/*
# data block to define the policy instead of a JSON string
data "aws_iam_policy_document" "access_ssm" {
  statement {
    actions   = ["ssm:DescribeParameters"]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    actions   = ["ssm:GetParameters", "ssm:GetParameter", "ssm:GetParametersByPath"]
    resources = ["arn:aws:ssm:::parameter/cluster_type/${local.cluster_type}*"]
    effect    = "Allow"
  }
  statement {
    actions   = ["ssm:GetParameters", "ssm:GetParameter", "ssm:GetParametersByPath"]
    resources = ["arn:aws:ssm:::parameter/cluster_repo/${local.type_repo}*"]
    effect    = "Allow"
  }
  statement {
    actions   = ["ssm:GetParameters", "ssm:GetParameter", "ssm:GetParametersByPath"]
    resources = ["arn:aws:ssm:::parameter/cluster/${var.cluster_name}*"]
    effect    = "Allow"
  }
}
*/

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    effect = "Allow"
  }
}

# Nifty shortcut to define data resource, then policy is from here:
# https://developer.hashicorp.com/terraform/tutorials/aws/aws-iam-policy

/*
resource "aws_iam_policy" "ssm_parameter_policy" {
  name        = "${local.cluster_type}-${var.cluster_name}-ssm-policy"
  description = "Allow salt master to access parameters for cluster ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.access_ssm.json
}
*/

resource "aws_iam_role" "salt_master_role" {
  name               = "${var.cluster_name}-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "salt_master_role" {
  role       = aws_iam_role.salt_master_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "salt_master_EC2_ro" {
  role       = aws_iam_role.salt_master_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "salt_master" {
  name = "salt_master_${var.cluster_name}"
  role = aws_iam_role.salt_master_role.name
}


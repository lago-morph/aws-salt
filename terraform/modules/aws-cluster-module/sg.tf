module "ssh_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "host-access"
  description = "Security group for access to hosts"
  vpc_id      = module.vpc.vpc_id

  ingress_rules       = ["all-all"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  /* Comment this out and set "all-all" ingress rules so I can test iptables 
  ingress_rules       = ["ssh-tcp", "saltstack-tcp", "http-80-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 60000
      to_port     = 65000
      protocol    = "tcp"
      description = "load balancer ports"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 8
      to_port     = 0
      protocol    = "icmp"
      description = "ping"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 5666
      to_port     = 5666
      protocol    = "tcp"
      description = "nagios nrpe"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
*/

  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}


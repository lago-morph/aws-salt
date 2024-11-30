variable "repository_source" {
  description = ".git file with host specifier"
  type        = string
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
}
variable "cluster_type" {
  type        = string
  description = "type of cluster"
}

variable "hostclass" {
  description = "json structure defining hosts in the cluster"

  type = list(object({
    class_name = string
    num_hosts  = number
    public_ip  = bool
  }))
}

variable "admin_users" {
  description = "Additional users to create to log into hosts"
  type = list(object({
    name        = string
    public_keys = list(string)
    sudo        = bool
  }))
  default = []
}

variable "instance_type" {
  description = "Type to use for cluster hosts"
  type        = string
  default     = "t3.medium"
}

variable "region" {
  description = "AWS region to use"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR for the VPC created"
  type        = string
  default     = "10.0.0.0/16"
}

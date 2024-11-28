variable "cluster_name" {
  description = "Cluster name"
  type        = string
  default     = "simple_cluster_name"
}

variable "cluster_data" {
  description = "json structure defining the cluster"

  type = object({
    cluster_type = string
    hostclass = list(object({
      class_name = string
      num_hosts  = number
      public_ip  = bool
    }))
  })

  default = {
    cluster_type = "simple_cluster_type"
    hostclass = [
      {
        class_name = "load-balancer"
        num_hosts  = 1
        public_ip  = true
      },
      {
        class_name = "webserver"
        num_hosts  = 3
        public_ip  = false
      }
    ]
  }
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
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC created"
  type        = string
  default     = "10.0.0.0/16"
}

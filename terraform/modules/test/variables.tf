variable "cluster-name" {
  description = "Cluster name"
  type        = string
  default = "simple-cluster-name"
}

variable "cluster-data" {
  description = "json structure defining the cluster"

  type = object({
    cluster-type = string
    hostclass = list(object({
      class-name = string
      num-hosts  = number
      public-ip  = bool
    }))
  })

  default = {
    cluster-type = "simple-cluster-type"
    hostclass = [
      {
        class-name = "load-balancer"
        num-hosts  = 1
        public-ip  = true
      },
      {
        class-name = "webserver"
        num-hosts  = 3
        public-ip  = false
      }
    ]
  }
}

variable "admin-users" {
  description = "Additional users to create to log into hosts"
  type = list(object({
    name        = string
    public_keys = list(string)
    sudo        = bool
  }))
  default = []
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


locals {

  cluster-instances = merge([for hc in var.cluster-data.hostclass :
    {for i in range(hc.num-hosts) :
      "${hc.class-name}-${i}" => {
                class_name = hc.class-name 
                public_ip = hc.public-ip
             }
  }]...)
  # The dots invoke "grouping mode" in the for loop.  Strange syntax.
  # https://stackoverflow.com/questions/71250499/nested-loops-and-looping-over-maps-in-terraform

}

resource "null_resource" "hostclass" {
  for_each = tomap(local.cluster-instances)
}


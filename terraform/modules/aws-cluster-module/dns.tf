resource "aws_route53_zone" "internal_dns" {
  name = "${var.cluster_name}.cluster"

  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

resource "aws_route53_record" "salt" {
  name    = "salt"
  zone_id = aws_route53_zone.internal_dns.zone_id
  type    = "CNAME"
  ttl     = 60
  records = ["salt-master.${var.cluster_name}.cluster"]
}

resource "aws_route53_record" "salt_master" {
  name    = "salt-master"
  zone_id = aws_route53_zone.internal_dns.zone_id
  type    = "A"
  ttl     = 60
  records = [aws_instance.salt_master.private_ip]
}

resource "aws_route53_record" "host" {
  for_each = tomap(local.cluster_instances)
  name     = each.key
  zone_id  = aws_route53_zone.internal_dns.zone_id
  type     = "A"
  ttl      = 60
  records  = [aws_instance.host[each.key].private_ip]
}

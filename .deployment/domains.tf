########################
#### Route53       #####
########################

data "aws_route53_zone" "frenchbtc-fr" {
  name = var.dns_zone_name
}

resource "aws_route53_record" "validation_lotus" {
  for_each = {
    for dvo in aws_acm_certificate.lotus.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true

  zone_id   = data.aws_route53_zone.frenchbtc-fr.zone_id
  name      = each.value.name
  type      = each.value.type
  records   = [ each.value.record ]
  ttl       = 10
}

resource "aws_route53_record" "lotus" {
  zone_id = data.aws_route53_zone.frenchbtc-fr.zone_id
  name    = var.lb_dns_record_lotus
  type    = "CNAME"
  ttl     = "10"
  records = [ aws_lb.lotus.dns_name ]
}

output "aws_route53_record-lotus" {
  value = var.lb_dns_record_lotus
}
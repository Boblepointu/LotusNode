###############################
#### Certificate validation ###
###############################

resource "aws_acm_certificate_validation" "lotus" {
  provider                = aws
  certificate_arn         = aws_acm_certificate.lotus.arn
  validation_record_fqdns = [ for record in aws_route53_record.validation_lotus : record.fqdn ]
}

###############################
#### Certificate lotus #####
###############################

resource "aws_acm_certificate" "lotus" {
  provider                  = aws
  domain_name               = var.lb_dns_record_lotus
  subject_alternative_names = [ "*.${var.lb_dns_record_lotus}" ]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}
data "aws_route53_zone" "domain" {
  name = "${var.domain_name}."
}

resource "aws_route53_record" "wildcard" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "*.${data.aws_route53_zone.domain.name}"
  type    = "A"

  alias {
    name                   = aws_alb.main.dns_name
    zone_id                = aws_alb.main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "basic" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = data.aws_route53_zone.domain.name
  type    = "A"

  alias {
    name                   = aws_alb.main.dns_name
    zone_id                = aws_alb.main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}", var.domain_name]
  validation_method = "DNS"


  lifecycle {
    create_before_destroy = true

    ignore_changes = [
      # https://github.com/terraform-aws-modules/terraform-aws-acm/issues/20
      subject_alternative_names,
    ]
  }
}

resource "aws_route53_record" "cert_validation" {
  name    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_type
  zone_id = data.aws_route53_zone.domain.id
  records = [aws_acm_certificate.cert.domain_validation_options.0.resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn = aws_acm_certificate.cert.arn

  validation_record_fqdns = [
    aws_route53_record.cert_validation.fqdn
  ]
}

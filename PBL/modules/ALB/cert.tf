# The entire section creates a certificate, public zone, and validates the certificate using DNS method.

# Create the certificate using a wildcard for all the domains created in your_domain.gq
resource "aws_acm_certificate" "fictionalcompany" {
  domain_name       = "*.fictionalcompany.ip-ddns.com"
  validation_method = "DNS"
  
}

# Calling the hosted zone
data "aws_route53_zone" "fictionalcompany" {
  name         = "fictionalcompany.ip-ddns.com"
  private_zone = false
}

# Selecting validation method
resource "aws_route53_record" "fictionalcompany" {
  for_each = {
    for dvo in aws_acm_certificate.fictionalcompany.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.fictionalcompany.zone_id
}

# Validate the certificate through DNS method
resource "aws_acm_certificate_validation" "fictionalcompany" {
  certificate_arn        = aws_acm_certificate.fictionalcompany.arn
  validation_record_fqdns = [for record in aws_route53_record.fictionalcompany : record.fqdn]
}

# Create records for tooling
resource "aws_route53_record" "tooling" {
  zone_id = data.aws_route53_zone.fictionalcompany.zone_id
  name    = "tooling.fictionalcompany.ip-ddns.com"
  type    = "A"

  alias {
    name                   = aws_lb.ext-alb.dns_name
    zone_id                = aws_lb.ext-alb.zone_id
    evaluate_target_health = true
  }
}

# Create records for WordPress
resource "aws_route53_record" "wordpress" {
  zone_id = data.aws_route53_zone.fictionalcompany.zone_id
  name    = "wordpress.fictionalcompany.ip-ddns.com"
  type    = "A"

  alias {
    name                   = aws_lb.ext-alb.dns_name
    zone_id                = aws_lb.ext-alb.zone_id
    evaluate_target_health = true
  }
}


#############################
# ACM for CloudFront (eu-west-1)
#############################
resource "aws_acm_certificate" "cert" {
  provider          = aws.MY_NETWORKING
  domain_name       = "*.${local.domain_name}"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

# DNS validation records
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }
  zone_id         = data.aws_route53_zone.main.zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 60
  records         = [each.value.value]
  allow_overwrite = true
}

# Validation complete trigger
resource "aws_acm_certificate_validation" "wildcard" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}



#############################
# ACM for CloudFront (us-east-1)
#############################
resource "aws_acm_certificate" "us" {
  provider          = aws.us_east_1
  domain_name       = "*.${local.domain_name}"
  validation_method = "DNS"
}

resource "aws_route53_record" "us_east_1_validation" {
  provider = aws.us_east_1

  for_each = {
    for dvo in aws_acm_certificate.us.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id         = data.aws_route53_zone.main.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "us_east_1" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.us.arn
  validation_record_fqdns = [for r in aws_route53_record.us_east_1_validation : r.fqdn]
}

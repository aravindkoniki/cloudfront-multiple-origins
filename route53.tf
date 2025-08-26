# #############################
# # Route53 DNS
# #############################
data "aws_route53_zone" "main" {
  provider     = aws.MY_NETWORKING
  name         = local.domain_name
  private_zone = false
}


resource "aws_route53_record" "cf_aliases" {
  for_each = toset(local.cf_alias)
  provider = aws.MY_NETWORKING
  zone_id  = data.aws_route53_zone.main.zone_id
  name     = each.key
  type     = "A"
  alias {
    name                   = aws_cloudfront_distribution.cf.domain_name
    zone_id                = aws_cloudfront_distribution.cf.hosted_zone_id
    evaluate_target_health = false
  }
}



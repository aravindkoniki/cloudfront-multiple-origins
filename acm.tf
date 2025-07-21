
#############################
# ACM for CloudFront (us-east-1)
#############################
resource "aws_acm_certificate" "us" {
  provider          = aws.us_east_1
  domain_name       = "*.${local.domain_name}"
  validation_method = "DNS"
}

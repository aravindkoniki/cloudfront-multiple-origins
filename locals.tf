locals {
  cf_alias    = ["test.${local.domain_name}", "dev.${local.domain_name}"]
  domain_name = "cloudcraftlab.work"

  s3_origins = {
    dev = {
      domain_name = aws_s3_bucket.dev.bucket_regional_domain_name
      origin_id   = "dev-origin"
    },
    test = {
      domain_name = aws_s3_bucket.test.bucket_regional_domain_name
      origin_id   = "test-origin"
    }
  }
}

output "s3_dev" {
  value = aws_s3_bucket.dev.bucket_regional_domain_name
}

output "s3_test" {
  value = aws_s3_bucket.test.bucket_regional_domain_name
}

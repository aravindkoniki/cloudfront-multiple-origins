resource "aws_s3_bucket" "test" {
  provider = aws.MY_NETWORKING
  bucket   = "test-cloudcraftlab-work"
}

resource "aws_s3_bucket_versioning" "test_versioning" {
  provider = aws.MY_NETWORKING
  bucket   = aws_s3_bucket.test.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_website_configuration" "test_spa" {
  provider = aws.MY_NETWORKING
  bucket   = aws_s3_bucket.test.id
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "spa" {
  provider                = aws.MY_NETWORKING
  bucket                  = aws_s3_bucket.test.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "test_index" {
  provider     = aws.pt_sandbox_test
  bucket       = aws_s3_bucket.test.id
  key          = "index.html"
  source       = "s3/test/index.html"
  content_type = "text/html"
}

resource "aws_s3_bucket_policy" "test_cloudfront_access" {
  provider = aws.MY_NETWORKING
  bucket   = aws_s3_bucket.test.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontAccessFromAccountA"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.test.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.cf.arn
          }
        }
      }
    ]
  })
}

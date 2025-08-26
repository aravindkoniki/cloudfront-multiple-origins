resource "aws_s3_bucket" "dev" {
  provider = aws.MY_NETWORKING
  bucket   = "dev-cloudcraftlab-work"
}

resource "aws_s3_bucket_versioning" "dev_versioning" {
  provider = aws.MY_NETWORKING
  bucket   = aws_s3_bucket.dev.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_website_configuration" "dev_spa" {
  provider = aws.MY_NETWORKING
  bucket   = aws_s3_bucket.dev.id
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "dev_spa" {
  provider                = aws.MY_NETWORKING
  bucket                  = aws_s3_bucket.dev.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "dev_index" {
  provider     = aws.MY_NETWORKING
  bucket       = aws_s3_bucket.dev.id
  key          = "index.html"
  source       = "s3/dev/index.html"
  content_type = "text/html"
}


resource "aws_s3_bucket_policy" "dev_cloudfront_access" {
  provider = aws.MY_NETWORKING
  bucket   = aws_s3_bucket.dev.id
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
        Resource = "${aws_s3_bucket.dev.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.cf.arn
          }
        }
      }
    ]
  })
}

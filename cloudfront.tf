# CloudFront OAC
resource "aws_cloudfront_origin_access_control" "oac" {
  provider                          = aws.MY_NETWORKING
  name                              = "cloudfront-s3-oac"
  description                       = "OAC for accessing S3 buckets"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


resource "aws_cloudfront_function" "viewer_request_function" {
  provider = aws.MY_NETWORKING
  name     = "viewer-request-redirect"
  runtime  = "cloudfront-js-2.0"
  comment  = "Redirect based on host header"
  publish  = true
  code     = file("cloudfront_function_code.js")
}


# CloudFront Distribution
resource "aws_cloudfront_distribution" "cf" {
  provider            = aws.MY_NETWORKING
  enabled             = true
  aliases             = local.cf_alias
  default_root_object = "index.html"

  dynamic "origin" {
    for_each = local.s3_origins
    content {
      domain_name              = origin.value.domain_name
      origin_id                = origin.value.origin_id
      origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    }
  }

  default_cache_behavior {
    allowed_methods          = ["GET", "HEAD", "OPTIONS"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = "test-origin" # Dummy value, will be replaced by the actual origin ID
    viewer_protocol_policy   = "redirect-to-https"
    compress                 = true
    cache_policy_id          = aws_cloudfront_cache_policy.custom_cache_policy.id                   #"658327ea-f89d-4fab-a63d-7e88639e58f6" # 4135ea2d-6df8-44a3-9df3-4b5a84be39ad
    origin_request_policy_id = aws_cloudfront_origin_request_policy.custom_origin_request_policy.id #"88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.viewer_request_function.arn
    }

    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = aws_lambda_function.edge_router.qualified_arn
      include_body = true
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.us.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "cf-multi-s3"
  }
}


resource "aws_cloudfront_cache_policy" "custom_cache_policy" {
  name    = "custom-cache-policy-with-header"
  comment = "Custom caching policy with custom header for CloudFront"

  default_ttl = 3600
  max_ttl     = 86400
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_gzip   = true
    enable_accept_encoding_brotli = true

    headers_config {
      header_behavior = "whitelist"

      headers {
        items = ["spa-custom-Header"] # actual custom header
      }
    }

    cookies_config {
      cookie_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_origin_request_policy" "custom_origin_request_policy" {
  name    = "custom-origin-request-policy-with-header"
  comment = "Custom policy to forward specific headers, cookies, and query strings"

  headers_config {
    header_behavior = "whitelist"

    headers {
      items = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method", "spa-custom-Header"] # actual custom header
    }
  }

  cookies_config {
    cookie_behavior = "none"
  }

  query_strings_config {
    query_string_behavior = "none"
  }
}

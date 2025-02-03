data aws_caller_identity current {}

resource "aws_cloudfront_distribution" "website_distribution" {
  depends_on = [time_sleep.dns_propagation]

  enabled             = true
  default_root_object = "index.html"
  is_ipv6_enabled     = true

  origin {
    domain_name              = var.bucket_domain
    origin_id                = var.bucket_name
    origin_access_control_id = aws_cloudfront_origin_access_control.website.id
  }

  aliases = [var.domain_name]
  default_cache_behavior {
    target_origin_id       = var.bucket_name
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }

      headers = ["Origin", "Content-Type"]
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = time_sleep.dns_propagation.triggers["certificate_arn"]
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method  = "sni-only"
  }

  tags = {
    Description = "Distribuicao do portal pessoal"
    Environment = var.environment
  }
}

resource "aws_cloudfront_origin_access_control" "website" {
  name                              = "cloudfront-s3-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "time_sleep" "dns_propagation" {
  create_duration = "5m"

  triggers = {
    certificate_arn = var.certificate
  }
}

resource "aws_route53_record" "name" {
  zone_id = var.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    zone_id                = aws_cloudfront_distribution.website_distribution.hosted_zone_id
    name                   = aws_cloudfront_distribution.website_distribution.domain_name
    evaluate_target_health = false
  }
}

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = var.bucket_name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowCloudFrontAccess"
        Principal = {
          "Service" = "cloudfront.amazonaws.com"
        }
        Effect    = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
        Condition = {
          "StringEquals": {
            "AWS:SourceArn": "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.website_distribution.id}"
          }
        }
      },
    ]
  })
}
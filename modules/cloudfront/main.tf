resource "aws_cloudfront_distribution" "site_distribution" {
  origin {
    domain_name = var.website_endpoint
    custom_origin_config {
      http_port              = 80
      https_port             = 80
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
    }
    origin_id = "${var.website_name}-${var.environment}-origin"
  }
  enabled             = true
  aliases             = ["${var.website_name}.com", "www.${var.website_name}.com"]
  price_class         = "PriceClass_100"
  default_root_object = "index.html"
  default_cache_behavior {
    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH",
    "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.website_name}-${var.environment}-origin"
    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 1000
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }
}

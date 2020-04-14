output "domain_name" {
  value = aws_cloudfront_distribution.site_distribution.domain_name
}

output "zone_id" {
  value = aws_cloudfront_distribution.site_distribution.hosted_zone_id
}

output "distribution_id" {
  value = aws_cloudfront_distribution.site_distribution.id
}
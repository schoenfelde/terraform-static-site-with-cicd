
resource "aws_route53_record" "base" {
  zone_id = var.r53_zone_id
  name    = "${var.website_name}.com"
  type = "A"
  alias {
    name                   = var.domain_name
    zone_id                = var.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www" {
  zone_id = var.r53_zone_id
  name    = "www.${var.website_name}.com"
  type = "A"
  alias {
    name                   = var.domain_name
    zone_id                = var.zone_id
    evaluate_target_health = true
  }
}

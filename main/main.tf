module "s3" {
  source          = "../modules/s3"
  website_name     = var.website_name
  environment      = var.environment
}

module "cloudfront" {
  source           = "../modules/cloudfront"
  website_endpoint = module.s3.website_endpoint
  website_name     = var.website_name
  acm_arn          = var.acm_arn
  environment      = var.environment
}

module "dns" {
  source           = "../modules/dns"
  r53_zone_id      = var.r53_zone_id
  website_name     = var.website_name
  domain_name      = module.cloudfront.domain_name
  zone_id          = module.cloudfront.zone_id
  environment      = var.environment
}

module "cicd" {
  source                      = "../modules/cicd"
  pipeline_name               = "${var.website_name}-${var.environment}"
  github_oauth_token          = var.github_oauth_token
  github_owner_name           = var.github_owner_name
  github_repo_name            = var.github_repo_name
  github_branch_name          = var.github_branch_name
  website_name                = var.website_name
  cloudfront_distribution_id  = module.cloudfront.distribution_id
}

data "aws_caller_identity" "this" {}
data "aws_availability_zones" "azs" {}

data "aws_acm_certificate" "bigtrade" {
  domain   = var.domain_name
  statuses = ["ISSUED"]
}

data "aws_secretsmanager_secret_version" "wordpress-secrets" {
  secret_id = "bigtrade-main-site-wordpress"
}

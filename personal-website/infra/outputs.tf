# main.tf
output "distribution_domain" {
  value = module.cloudfront.distribution_domain
}

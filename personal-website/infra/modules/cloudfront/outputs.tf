output "distribution_id" {
  description = "Id da distribuicao"
  value       = aws_cloudfront_distribution.website_distribution.id
}

output "distribution_domain" {
  value = aws_cloudfront_distribution.website_distribution.domain_name
}
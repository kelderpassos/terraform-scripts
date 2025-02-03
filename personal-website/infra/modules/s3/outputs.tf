# module s3
output "bucket_domain" {
  description = "Domínio do bucket"
  value       = aws_s3_bucket.website_bucket.bucket_domain_name
}

output "bucket_endpoint" {
  description = "Ponto de acesso ao bucket"
  value       = aws_s3_bucket_website_configuration.website_configuration.website_endpoint
}

output "bucket_name" {
  description = "Nome do bucket"
  value       = aws_s3_bucket.website_bucket.id
}

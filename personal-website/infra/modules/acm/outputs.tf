output "certificate_arn" {
  value = aws_acm_certificate.website_cert.arn
}

output "certificate_validation" {
  description = "Conjunto de opções de validacao"
  value       = aws_acm_certificate.website_cert.domain_validation_options
}
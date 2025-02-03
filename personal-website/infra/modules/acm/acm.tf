resource "aws_acm_certificate" "website_cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.domain_name}-certificate"
    Environment = var.environment
  }
}

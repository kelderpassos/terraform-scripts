resource "aws_route53_zone" "website_zone" {
  name = var.domain_name

  tags = {
    Description = "Zona hospedada do portal pessoal"
    Environment = var.environment
  }
}

resource "aws_route53_record" "website_record" {
  for_each = {
    for dvo in var.certificate_validation : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.website_zone.id
}

resource "aws_route53domains_registered_domain" "update_ns" {
  depends_on  = [aws_route53_record.website_record]
  domain_name = var.domain_name

  dynamic "name_server" {
    for_each = aws_route53_zone.website_zone.name_servers
    content {
      name = name_server.value
    }
  }

  tags = {
    Environment = var.environment
  }
}


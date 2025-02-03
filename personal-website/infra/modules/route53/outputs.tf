# module route53
output "zone_id" {
  value = aws_route53_zone.website_zone.zone_id
}
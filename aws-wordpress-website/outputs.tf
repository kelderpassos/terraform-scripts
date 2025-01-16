output "wordpress_public_ip" {
  description = "ID publico da instancia"
  value = module.wordpress.public_ip
}

output "ec2_endpoint" {
  description = "Nome DNS da instancia"
  value = module.wordpress.ec2_endpoint
}

output "rds_endpoint" {
  description = "Ponto de acesso da instancia MySQL"
  value = module.wordpress.rds_endpoint
}

output "elastic_ip" {
  description = "IP dedicado da instancia"
  value = module.wordpress.elastic_ip
}
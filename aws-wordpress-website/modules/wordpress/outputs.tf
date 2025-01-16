# vpc
output "vpc_id" {
  description = "ID da VPC"
  value = aws_vpc.main.id
}

output "ec2_security_group_id" {
  description = "ID do security group"
  value = aws_security_group.vpc.id
}

output "public_subnet_az1_id" {
  description = "ID da subnet publica 1"
  value = aws_subnet.public_1.id
}

output "public_subnet_az2_id" {
  description = "ID da subnet publica 2"
  value = aws_subnet.public_2.id
}

output "elastic_ip" {
  description = "IP dedicado da instancia"
  value = aws_eip.elastic_ip.public_ip
}

# ec2
output "instance_id" {
  description = "ID da instancia"
  value = aws_instance.wordpress.id
}

output "public_ip" {
  description = "ID publico da instancia"
  value = aws_instance.wordpress.public_ip
} 

output "ec2_endpoint" {
  description = "Nome DNS da instancia"
  value = aws_instance.wordpress.public_dns
}

output "rds_endpoint" {
  description = "Ponto de acesso da instancia MySQL"
  value = aws_db_instance.wordpress_db.endpoint
}
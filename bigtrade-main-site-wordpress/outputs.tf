output "wordpress_public_ip" {
  value = module.wordpress.public_ip
}

output "az1" {
  value = data.aws_availability_zones.azs.names[0]
}

output "az2" {
  value = data.aws_availability_zones.azs.names[1]
}

output "az3" {
  value = data.aws_availability_zones.azs.names[2]
}
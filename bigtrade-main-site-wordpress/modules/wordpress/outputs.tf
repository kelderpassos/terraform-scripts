output "public_ip" {
  value = "http://${aws_instance.wordpress.public_ip}"
} 

output "instance_id" {
  value = aws_instance.wordpress.id
}

output "ec2_security_group_id" {
  value = aws_security_group.vpc.id
}

output "public_subnet_az1_id" {
  value = aws_subnet.public_1.id
}

output "public_subnet_az2_id" {
  value = aws_subnet.public_2.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

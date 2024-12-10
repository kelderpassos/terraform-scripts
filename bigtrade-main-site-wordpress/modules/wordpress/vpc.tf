# vpc
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support = "true"
  enable_dns_hostnames = "true"
  instance_tenancy = "default"

  tags = {
    name = "${var.project_name}-vpc"
    created_at = timestamp()
  }
}

# subnet publica
resource "aws_subnet" "public_1" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet1
  availability_zone = var.az1
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-1"
    subnet_type = "public"
    created_at = timestamp()
  }
}

resource "aws_subnet" "public_2" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet2
  availability_zone = var.az2
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-2"
    subnet_type = "public"
    created_at = timestamp()
  }
}

# subnet privada
resource "aws_subnet" "private_1" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnet1
  availability_zone = var.az2

  tags = {
    Name = "${var.project_name}-private-subnet-1"
    subnet_type = "private"
    created_at = timestamp()
  }
}

resource "aws_subnet" "private_2" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnet2
  availability_zone = var.az3

  tags = {
    Name = "${var.project_name}-private-subnet-2"
    subnet_type = "private"
    created_at = timestamp()
  }
}

# subnet para rds
resource "aws_db_subnet_group" "rds_subnet_grp" {
  subnet_ids = ["${aws_subnet.private_1.id}", "${aws_subnet.private_2.id}"]

  tags = {
    name = "${var.project_name}-private-subnet-2"
    subnet_type = "private"
    created_at = timestamp()
  }
}

# internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    name = "${var.project_name}-igw"
    created_at = timestamp()
  }
}

# nat gateway
# resource "aws_nat_gateway" "nat_gateway" {
#   allocation_id = aws_eip.elastic_ip.id
#   subnet_id = aws_subnet.public_1.id

#   tags = {
#     name = "bigtrade-vpc-nat-gateway"
#     created_at = timestamp()
#   }
# }

# elastic ip
resource "aws_eip" "elastic_ip" {
  depends_on = [aws_vpc.main, aws_internet_gateway.igw]

  domain = "vpc"

  tags = {
    name = "bigtrade-vpc-eip"
    created_at = timestamp()
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id = aws_instance.wordpress.id
  allocation_id = aws_eip.elastic_ip.id
}

# route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    name = "${var.project_name}-public-rt"
    rt_type = "public"
    created_at = timestamp()
  }
}

resource "aws_route_table_association" "public_1" {
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.public_1.id
}

# resource "aws_route_table" "private" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat_gateway.id
#   }

#   tags = {
#     name = "bigtrade-vpc-private-rt"
#     rt_type = "private"
#     created_at = timestamp()
#   }
# }

# resource "aws_route_table_association" "public_2" {
#   route_table_id = aws_route_table.public.id
#   subnet_id = aws_subnet.public_2.id
# }

# resource "aws_route_table_association" "private_1" {
#   route_table_id = aws_route_table.private.id
#   subnet_id = aws_subnet.private_1.id
# }

# resource "aws_route_table_association" "private_2" {
#   route_table_id = aws_route_table.private.id
#   subnet_id = aws_subnet.private_2.id
# }

# security group para ec2
resource "aws_security_group" "vpc" {
  name = "main_vpc_security_group"
  vpc_id = aws_vpc.main.id
  description = "Habilita trafego de entrada e saida para a VPC"

  tags = {
    name = "${var.project_name}-sg"
    created_at = timestamp()
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.vpc.id
  description = "Habilita trafego de saida de todas as portas"
  ip_protocol = "-1"
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 0
  to_port = 0
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.vpc.id
  description = "Habilita trafego de entrada SSH"
  ip_protocol = "tcp"
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 22
  to_port = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.vpc.id
  description = "Habilita trafego de entrada HTTPS"
  ip_protocol = "tcp"
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 443
  to_port = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.vpc.id
  description = "Habilita trafego de entrada HTTP"
  ip_protocol = "tcp"
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 80
  to_port = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_mysql" {
  security_group_id = aws_security_group.vpc.id
  description = "Habilita trafego de entrada p/ RDS"
  ip_protocol = "tcp"
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 3306
  to_port = 3306
}

# security group para rds
resource "aws_security_group" "rds" {
  name = "rds_vpc_security_group"
  vpc_id = aws_vpc.main.id
  description = "Habilita trafego do EC2 p/ RDS"

  tags = {
    name = "${var.project_name}-sg-rds"
    created_at = timestamp()
  }
}

resource "aws_vpc_security_group_ingress_rule" "name" {
  security_group_id = aws_security_group.rds.id
  description = "Habilita trafego de entrada p/ RDS"
  ip_protocol = "tcp"
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 3306
  to_port = 3306
}





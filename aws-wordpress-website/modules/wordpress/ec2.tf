# arquivo user-data
data "template_file" "userdata" {
  template = file("${path.module}/userdata.sh")

  vars = {
    db_name = var.database_name
    db_username = var.database_username
    db_password = var.database_password
    db_endpoint = substr(aws_db_instance.wordpress_db.endpoint, 0, length(aws_db_instance.wordpress_db.endpoint) - 5)
  }
}

# instancia ec2
resource "aws_instance" "wordpress" {
  depends_on = [ aws_db_instance.wordpress_db ]

  ami = var.aws_ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.public_1.id
  vpc_security_group_ids = [ "${aws_security_group.vpc.id}" ]
  associate_public_ip_address = true
  user_data = data.template_file.userdata.rendered
  key_name = var.key_name

  root_block_device {
    volume_size = var.root_volume_size
  }

  tags = {
    Name = "${var.project_name}-instance"
    created_at = timestamp()
  }
}

# instancia rds
resource "aws_db_instance" "wordpress_db" {
  instance_class = var.instance_class
  allocated_storage = 20
  engine = "mysql"
  engine_version = "8.4.3"
  storage_encrypted = true
  multi_az = true
  skip_final_snapshot = false
  final_snapshot_identifier = "${var.database_name}-${var.random}"

  db_subnet_group_name = aws_db_subnet_group.rds_subnet_grp.id
  vpc_security_group_ids = [ "${aws_security_group.rds.id}" ]
  
  db_name = var.database_name
  identifier = "bigtrade-wordpress-rds"
  username = var.database_username
  password = var.database_password

  tags = {
    Name = "${var.project_name}-rds"
    created_at = timestamp()
  }
}

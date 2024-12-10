# arquivo user-data
data "template_file" "userdata" {
  template = file("${path.module}/userdata.tpl")

  vars = {
    db_name = var.database_name
    db_username = var.database_username
    db_password = var.database_password
    db_endpoint = aws_db_instance.wordpress_db.endpoint
  }
}

resource "aws_key_pair" "wordpress_key_pair" {
  key_name = "bigtrade-wordpress-site-key"
  public_key = file(var.pub_key)
}

resource "aws_instance" "wordpress" {
  depends_on = [ aws_db_instance.wordpress_db ]

  ami = var.aws_ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.public_1.id
  vpc_security_group_ids = [ "${aws_security_group.vpc.id}" ]
  user_data = data.template_file.userdata.rendered
  key_name = aws_key_pair.wordpress_key_pair.id

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
  allocated_storage = 10
  engine = "mysql"
  engine_version = "8.4.3"
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_grp.id
  vpc_security_group_ids = [ "${aws_security_group.rds.id}" ]
  db_name = var.database_name
  username = var.database_username
  password = var.database_password
  skip_final_snapshot = false
  final_snapshot_identifier = "${var.database_name}-${var.random}"

  tags = {
    Name = "${var.project_name}-rds"
    created_at = timestamp()
  }
}
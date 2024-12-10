resource "null_resource" "wordpress_installation" {
  depends_on = [aws_instance.wordpress]

  triggers = {
    ec2_id = aws_instance.wordpress.id
    rds_endpoint = aws_db_instance.wordpress_db.id
  }

  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file(var.prv_key)
    host = aws_eip.elastic_ip.public_ip
  }

  provisioner "remote-exec" {
    inline = [ "sudo tail -f -n0 /var/log/cloud-init-output.log | grep -q 'Wordpress Installed'" ]
  }
}
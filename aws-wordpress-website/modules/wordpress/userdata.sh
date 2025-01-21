#!/bin/bash

# instala dependencias necessarias
sudo dnf update -y
sudo dnf install httpd mariadb105 php php-cli php-mysqlnd php-mbstring php-xml -y
sudo dnf install  -y

# inicia apache
sudo systemctl start httpd && sudo systemctl enable httpd

# instala wordpress
curl -O https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
sudo cp -r wordpress/* /var/www/html/
sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

# executa wordpress sobre com apache como usuario
sudo chown -R apache:apache /var/www/html/
sudo rm -rf wordpress lastest.tar.gz

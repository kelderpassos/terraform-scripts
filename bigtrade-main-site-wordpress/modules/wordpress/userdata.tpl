#!/bin/bash

# variaveis do Terraform
db_name=${db_name}
db_username=${db_username}
db_password=${db_password}
db_endpoint=${db_endpoint}

# instala dependencias necessarias
yum update -y
yum install httpd -y
yum install mysql -y

# instala e configura php e suas extensoes
amazon-linux-extras enable php7.4
yum clean metadata
yum install -y php php-{pear,cgi,common,curl,mbstring,gd,mysqlnd,gettext,bcmath,json,xml,fpm,intl,zip,imap,devel}

yum install gcc ImageMagick ImageMagick-devel ImageMagick-perl -y
pecl install imagick
chmod 755 /usr/lib64/php/modules/imagick.so
cat <<EOF >>/etc/php.d/20-imagick.ini

extension=imagick

EOF

systemctl restart php-fpm.service
systemctl start  httpd

# muda proprietario e permissao do diretorio /var/www
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;

# instala wordpress usando a wp-cli
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
wp core download --path=/var/www/html --allow-root
wp config create --dbname=$db_name --dbuser=$db_username --dbpass=$db_user_password --dbhost=$db_RDS --path=/var/www/html --allow-root --extra-php <<PHP
define( 'FS_METHOD', 'direct' );
define('WP_MEMORY_LIMIT', '128M');
PHP

# muda permissao do diretorio /var/www/html/
chown -R ec2-user:apache /var/www/html
chmod -R 774 /var/www/html

#  habilita arquivos .htaccess no Apache config a usar o comando sed
sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride all/' /etc/httpd/conf/httpd.conf

# faz apache autoiniciar e reiniciar
systemctl enable  httpd.service
systemctl restart httpd.service
echo WordPress Installed


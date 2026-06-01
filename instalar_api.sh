#!/bin/bash

echo "====================================="
echo " DESPLIEGUE API LIBROS - LARAVEL 13 "
echo "====================================="

apt update -y
apt upgrade -y

echo "Instalando Apache..."
apt install -y apache2

echo "Instalando MariaDB..."
apt install -y mariadb-server mariadb-client

echo "Instalando PHP y extensiones..."
apt install -y php php-cli php-common php-mysql php-mbstring php-xml php-curl php-zip php-bcmath unzip curl git

echo "Instalando Composer..."
cd /tmp

curl -sS https://getcomposer.org/installer -o composer-setup.php

php composer-setup.php

mv composer.phar /usr/local/bin/composer

chmod +x /usr/local/bin/composer

echo "Iniciando servicios..."

systemctl enable apache2
systemctl start apache2

systemctl enable mariadb
systemctl start mariadb

echo "Creando base de datos..."

mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS api1;
EOF

echo "Clonando proyecto..."

cd /var/www

rm -rf Api-libros

git clone https://github.com/fatimaraglez-wq/Api-libros.git

cd Api-libros

echo "Instalando dependencias Laravel..."

composer install --no-interaction --prefer-dist --optimize-autoloader

echo "Configurando entorno..."

cp .env.example .env

php artisan key:generate

sed -i 's/DB_DATABASE=.*/DB_DATABASE=api1/' .env

php artisan config:clear

echo "Ejecutando migraciones..."

php artisan migrate --force

echo "Configurando permisos..."

chown -R www-data:www-data /var/www/Api-libros

chmod -R 775 storage

chmod -R 775 bootstrap/cache

echo "Configurando Apache..."

cat > /etc/apache2/sites-available/apilibros.conf <<EOF
<VirtualHost *:80>

    ServerAdmin admin@localhost

    DocumentRoot /var/www/Api-libros/public

    <Directory /var/www/Api-libros/public>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/apilibros_error.log
    CustomLog \${APACHE_LOG_DIR}/apilibros_access.log combined

</VirtualHost>
EOF

a2enmod rewrite

a2dissite 000-default.conf

a2ensite apilibros.conf

systemctl restart apache2

echo ""
echo "====================================="
echo " DESPLIEGUE COMPLETADO "
echo "====================================="
echo ""
echo "API disponible en:"
echo "http://IP_DEL_SERVIDOR"

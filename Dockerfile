# Utiliza la imagen oficial de PHP 8.2 con Apache en Alpine Linux
FROM php:8.2-apache

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /var/www/html

# Copia el contenido del directorio actual en el contenedor
COPY . .

# Instala extensiones de PHP necesarias, por ejemplo mysqli y pdo_mysql
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Expone el puerto 80 para Apache
EXPOSE 80
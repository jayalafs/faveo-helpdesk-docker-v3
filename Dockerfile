# Dockerfile
FROM ubuntu:jammy

# Configurar las variables de entorno para la instalación no interactiva
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Asuncion

# Actualizar el sistema e instalar paquetes necesarios
RUN apt-get update && \
    apt-get install -y tzdata software-properties-common cron && \
    apt-get install -y \
        apache2 \
        php8.1 \
        php8.1-fpm \
        libapache2-mod-php8.1 \
        php8.1-mysql \
        php8.1-cli \
        php8.1-common \
        php8.1-soap \
        php8.1-gd \
        php8.1-opcache \
        php8.1-mbstring \
        php8.1-zip \
        php8.1-bcmath \
        php8.1-intl \
        php8.1-xml \
        php8.1-curl \
        php8.1-imap \
        php8.1-ldap \
        php8.1-gmp \
        php8.1-redis \
        git \
        wget \
        curl \
        unzip \
        nano \
        zip \
        wkhtmltopdf && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Crear el directorio de sockets para php-fpm
RUN mkdir -p /run/php && chown -R www-data:www-data /run/php

# Copiar el archivo php.ini
COPY ./src/php.ini /etc/php/8.1/fpm/php.ini
COPY ./src/php.ini /etc/php/8.1/cli/php.ini

# Copiar la configuración de Apache para Faveo
COPY ./src/faveo.conf /etc/apache2/sites-available/faveo.conf

# Descargar ionCube y descomprimirlo
RUN wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz && \
    tar xvfz ioncube_loaders_lin_x86-64.tar.gz && \
    rm ioncube_loaders_lin_x86-64.tar.gz

# Configurar ionCube
RUN PHP_EXTENSION_DIR=$(php -i | grep "extension_dir" | awk '{print $3}') && \
    cp ioncube/ioncube_loader_lin_8.1.so "$PHP_EXTENSION_DIR" && \
    echo "zend_extension=$PHP_EXTENSION_DIR/ioncube_loader_lin_8.1.so" >> /etc/php/8.1/fpm/php.ini && \
    echo "zend_extension=$PHP_EXTENSION_DIR/ioncube_loader_lin_8.1.so" >> /etc/php/8.1/cli/php.ini

# Descargar Faveo Helpdesk desde GitHub
RUN git clone https://github.com/ladybirdweb/faveo-helpdesk.git /var/www/html/faveo

# Establecer permisos
RUN chown -R www-data:www-data /var/www/html/faveo && \
    find /var/www/html/faveo -type f -exec chmod 644 {} \; && \
    find /var/www/html/faveo -type d -exec chmod 755 {} \;

# Configurar Apache para utilizar el sitio Faveo
RUN a2enmod rewrite && \
    a2dissite 000-default.conf && \
    a2ensite faveo.conf && \
    a2enmod proxy_fcgi setenvif && \
    a2enconf php8.1-fpm && \
    service php8.1-fpm restart && \
    service apache2 restart

# Configurar cron para www-data
RUN (crontab -l -u www-data 2>/dev/null; echo "* * * * * /usr/bin/php /var/www/html/faveo/artisan schedule:run >> /var/log/cron.log 2>&1") | crontab -u www-data -

# Exponer el puerto 80
EXPOSE 80

# Comando por defecto para mantener el contenedor en ejecución
CMD ["tail", "-f", "/dev/null"]
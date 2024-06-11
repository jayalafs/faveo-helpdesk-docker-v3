# Dockerfile para una aplicación PHP con Apache

# Utilizar la imagen base de PHP con Apache
FROM php:8.2-apache

# Actualizar el sistema y los repositorios
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libwebp-dev \
        libxpm-dev \
        libvpx-dev \
        libldb-dev \
        libldap2-dev \
        libicu-dev \
        libxml2-dev \
        libkrb5-dev \
        libgmp-dev \
        libc-client-dev \
        libssl-dev \
        libbz2-dev \
        libcurl4-openssl-dev \
        libzip-dev \
        libmemcached-dev \
        cron \
        git \
        wget \
        curl \
        unzip \
        nano \
        libonig-dev \
        wkhtmltopdf \
        libfcgi0ldbl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Configurar la extensión GD e IMAP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl

# Instalar las extensiones de PHP
RUN docker-php-ext-install -j$(nproc) \
    pdo_mysql \
    mbstring \
    zip \
    exif \
    pcntl \
    bcmath \
    opcache \
    gd \
    soap \
    intl \
    xml \
    curl \
    imap \
    ldap \
    gmp

# Instalar y habilitar la extensión memcached
RUN pecl install memcached && docker-php-ext-enable memcached

# Instalar y habilitar la extensión Redis
RUN pecl install redis && docker-php-ext-enable redis

# Copiar el archivo php.ini
COPY ./src/php.ini /usr/local/etc/php/php.ini

# Copiar el código de Faveo y la configuración de Apache
COPY ./src/faveo.conf /etc/apache2/sites-available/faveo.conf

# Descargar ionCube y descomprimirlo
RUN wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz && \
    tar xvfz ioncube_loaders_lin_x86-64.tar.gz && \
    rm ioncube_loaders_lin_x86-64.tar.gz

# Determinar la carpeta de las extensiones PHP
RUN PHP_EXTENSION_DIR=$(php -i | grep "extension_dir" | awk '{print $3}') && \
    cp ioncube/ioncube_loader_lin_8.2.so "$PHP_EXTENSION_DIR" && \
    echo "zend_extension=\"$PHP_EXTENSION_DIR/ioncube_loader_lin_8.2.so\"" >> /usr/local/etc/php/php.ini

# Configurar Apache para utilizar el sitio Faveo
RUN a2enmod rewrite

# Exponer el puerto 80
EXPOSE 80

# Comando para iniciar Apache en el contenedor
CMD ["apache2-foreground"]
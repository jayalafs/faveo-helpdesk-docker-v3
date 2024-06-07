FROM php:8.2-apache

# Actualizar el sistema y los repositorios
RUN apt-get update && apt-get upgrade -y

# Instalar las dependencias necesarias en grupos más pequeños
RUN apt-get update && apt-get install -y \
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
    libonig-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Configurar la extensión GD e IMAP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl

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

# Habilitar mod_rewrite
RUN a2enmod rewrite

# Exponer el puerto 80
EXPOSE 80
#Anotaciones

/etc/apache2
/etc/apache2/sites-available/

/usr/local/etc/php

docker-compose up -d



cp ioncube/ioncube_loader_lin_8.1.so /usr/local/lib/php/extensions/no-debug-non-zts-20220829
echo 'zend_extension = "/usr/local/lib/php/extensions/no-debug-non-zts-20220829/ioncube_loader_lin_8.1.so"' >> /usr/local/etc/php/php.ini

# Directorio
C:\Proyect\faveo-helpdesk-docker-v3\
│
├── docker-comopse.ymal
├── Dockerfile
├── src\
│   ├── faveo\
│   │   └── ... (código de Faveo)
│   ├── php.ini
│   └── faveo.conf


# Copiar el archivo php.ini
COPY ./src/php.ini /usr/local/etc/php/php.ini

# Descargar ionCube y descomprimirlo
RUN wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz && \
    tar xvfz ioncube_loaders_lin_x86-64.tar.gz && \
    rm ioncube_loaders_lin_x86-64.tar.gz

# Determinar la carpeta de las extensiones PHP
RUN PHP_EXTENSION_DIR=$(php -i | grep "extension_dir" | awk '{print $3}') && \
    cp ioncube/ioncube_loader_lin_8.2.so "$PHP_EXTENSION_DIR" && \
    echo "zend_extension=\"$PHP_EXTENSION_DIR/ioncube_loader_lin_8.2.so\"" >> /usr/local/etc/php/php.ini

# Crear la carpeta faveo y establecer permisos
RUN mkdir -p /var/www/html/faveo && \
    chown -R www-data:www-data /var/www/html/faveo && \
    find /var/www/html/faveo -type f -exec chmod 644 {} \; && \
    find /var/www/html/faveo -type d -exec chmod 755 {} \;

# Copiar el código de Faveo y la configuración de Apache
COPY ./src/faveo /var/www/html/faveo
COPY ./src/faveo.conf /etc/apache2/sites-available/

# Configurar Apache para usar el sitio Faveo
RUN a2ensite faveo.conf && \
    a2dissite 000-default.conf


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

# Instalar y habilitar la extensión FPM
RUN docker-php-ext-install -j$(nproc) fpm

# Configurar Apache para PHP-FPM
COPY php8.2-fpm.conf /etc/apache2/conf-available/php8.2-fpm.conf
RUN a2enmod proxy_fcgi setenvif && \
    a2enconf php8.2-fpm
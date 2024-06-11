#Anotaciones

/etc/apache2
/etc/apache2/sites-available/

/usr/local/etc/php

docker-compose up -d

docker exec -it app-faveo bash

docker system prune -a


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

# Instalar y habilitar la extensión FPM
RUN docker-php-ext-install -j$(nproc) fpm

# Configurar Apache para PHP-FPM
COPY ./src/php8.2-fpm.conf /etc/apache2/conf-available/php8.2-fpm.conf
RUN a2enmod proxy_fcgi setenvif && \
    a2enconf php8.2-fpm

# Configurar Apache para utilizar el sitio Faveo
RUN a2ensite faveo.conf && \
    a2dissite 000-default.conf && \
    a2enmod rewrite
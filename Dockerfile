# Dockerfile para una aplicación PHP con Apache

# Utilizar la imagen base de Ubuntu 22.04
FROM ubuntu:22.04

# Instalar Apache y PHP
RUN apt-get update && apt-get install -y apache2 php

# Exponer el puerto 80
EXPOSE 80
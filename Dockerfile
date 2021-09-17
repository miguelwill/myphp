FROM php:7.4.23-apache-bullseye
MAINTAINER miguelwill@gmail.com

#ENV Variables for OPCACHE
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="1" \
    PHP_OPCACHE_MAX_ACCELERATED_FILES="10000" \
    PHP_OPCACHE_MEMORY_CONSUMPTION="192" \
    PHP_OPCACHE_MAX_WASTED_PERCENTAGE="10"

#install dev packages
RUN export DEBIAN_FRONTEND=noninteractive && \
  apt update && \
  apt-get -y upgrade && \
#  apt install -y --no-install-recommends apache2-dev default-libmysqlclient-dev && \
#  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

#Install modules in php
RUN docker-php-ext-install mysqli pdo pdo_mysql opcache

#Copy opcache config file
COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini

#Enable apache2 modules
RUN a2enmod rewrite ssl

#Copy php configuracion production
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

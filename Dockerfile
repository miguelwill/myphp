FROM php:5.6-apache
MAINTAINER miguelwill@gmail.com

#ENV Variables for OPCACHE
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="1" \
    PHP_OPCACHE_MAX_ACCELERATED_FILES="10000" \
    PHP_OPCACHE_MEMORY_CONSUMPTION="192" \
    PHP_OPCACHE_MAX_WASTED_PERCENTAGE="10"


RUN apt-get update -y \
        && apt-get install -y libxml2-dev zlib1g-dev zip imagemagick pdftk libpng-dev \
        && apt-get clean -y

#Install modules in php
RUN docker-php-ext-install mysqli pdo pdo_mysql opcache zip soap gd mbstring

#Copy opcache config file
COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini

#Enable apache2 modules
RUN a2enmod rewrite ssl

#Copy php configuracion production
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

FROM php:7.4.33-apache-bullseye
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
  apt install -y --no-install-recommends libxml2-dev zlib1g-dev libzip4 libzip-dev zip imagemagick pdftk libpng-dev libonig-dev ssmtp libmagickwand-dev libxslt-dev && \
  apt clean && \
  rm -rf /var/lib/apt/lists/*

#Install modules in php
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install gd
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install intl
RUN docker-php-ext-install pdo
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install opcache
RUN docker-php-ext-install zip
RUN docker-php-ext-install soap
RUN docker-php-ext-install calendar
RUN docker-php-ext-install exif

RUN mkdir -p /usr/src/php/ext/msgpack; \
    curl -fsSL https://github.com/msgpack/msgpack-php/archive/refs/tags/msgpack-2.2.0.tar.gz | tar xvz -C "/usr/src/php/ext/msgpack" --strip 1; \
    docker-php-ext-install msgpack;

RUN docker-php-ext-install pcntl
RUN docker-php-ext-install shmop
RUN docker-php-ext-install sysvmsg sysvsem sysvshm
#RUN docker-php-ext-install wddx
RUN docker-php-ext-install xmlrpc
RUN docker-php-ext-install xsl

RUN mkdir -p /usr/src/php/ext/imagick; \
    curl -fsSL https://github.com/Imagick/imagick/archive/06116aa24b76edaf6b1693198f79e6c295eda8a9.tar.gz | tar xvz -C "/usr/src/php/ext/imagick" --strip 1; \
    docker-php-ext-install imagick;

RUN docker-php-ext-install memcache

#Copy opcache config file
COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini

#Enable apache2 modules
RUN a2enmod rewrite ssl

#Copy php configuracion production
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

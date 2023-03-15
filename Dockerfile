FROM php:8.1-apache-bullseye
MAINTAINER miguelwill@gmail.com

#ENV Variables for OPCACHE
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="1" \
    PHP_OPCACHE_MAX_ACCELERATED_FILES="10000" \
    PHP_OPCACHE_MEMORY_CONSUMPTION="192" \
    PHP_OPCACHE_MAX_WASTED_PERCENTAGE="10" \
    APACHE_RPAF_PROXY_IPS="172.16.0.1"

#install dev packages
RUN export DEBIAN_FRONTEND=noninteractive && \
  apt update && \
  apt-get -y upgrade && \
  apt install -y --no-install-recommends git libxml2-dev zlib1g-dev libzip4 libzip-dev zip imagemagick pdftk libpng-dev libonig-dev libcurl4 libcurlpp-dev libz-dev libmemcached-dev libmemcached11 libapache2-mod-rpaf && \
  apt clean && \
  rm -rf /var/lib/apt/lists/*

#Install memcached module for php
RUN git clone -b v3.2.0 https://github.com/php-memcached-dev/php-memcached /usr/src/php/ext/memcached \
    && docker-php-ext-configure /usr/src/php/ext/memcached \
        --disable-memcached-sasl \
    && docker-php-ext-install /usr/src/php/ext/memcached \
    && rm -rf /usr/src/php/ext/memcached

#Install modules in php
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install gd
RUN docker-php-ext-install mysqli pdo pdo_mysql opcache zip soap
RUN docker-php-ext-install xml curl

RUN pecl install redis && docker-php-ext-enable redis


#Copy opcache config file
COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY mpm_prefork.conf /etc/apache2/mods-available/mpm_prefork.conf
COPY rpaf.conf /etc/apache2/mods-available/rpaf.conf

#Enable apache2 modules
RUN a2enmod rewrite ssl

#Copy php configuracion production
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

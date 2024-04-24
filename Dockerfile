#FROM php:7.4.33-fpm-bullseye
FROM php:7.0-fpm
MAINTAINER miguelwill@gmail.com

#ENV Variables for OPCACHE
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="1" \
    PHP_OPCACHE_MAX_ACCELERATED_FILES="10000" \
    PHP_OPCACHE_MEMORY_CONSUMPTION="192" \
    PHP_OPCACHE_MAX_WASTED_PERCENTAGE="10"

#install dev packages
RUN echo "deb http://archive.debian.org/debian stretch main contrib non-free" > /etc/apt/sources.list

RUN export DEBIAN_FRONTEND=noninteractive && \
  apt-get update && \
  apt-get install -y --no-install-recommends --force-yes git vim zlib1g-dev libxml2-dev libzip4 libzip-dev zip imagemagick pdftk libpng-dev libonig-dev libxslt-dev libmagickwand-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

#add timezonedb
RUN docker-php-source extract \
    && pecl bundle -d /usr/src/php/ext timezonedb \
    && docker-php-ext-configure timezonedb \
    && docker-php-ext-install -j$(nproc) timezonedb \
    && docker-php-source delete

#Install modules in php
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install gd
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install pdo
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install opcache
RUN docker-php-ext-install zip
RUN docker-php-ext-install soap
RUN docker-php-ext-install calendar
RUN docker-php-ext-install exif
RUN docker-php-ext-install wddx
RUN docker-php-ext-install gettext
RUN docker-php-ext-install xsl

RUN pecl install igbinary \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable igbinary

#RUN docker-php-ext-install igbinary
#RUN docker-php-ext-install msgpack

RUN mkdir -p /usr/src/php/ext/msgpack; \
    curl -fsSL https://github.com/msgpack/msgpack-php/archive/refs/tags/msgpack-2.0.2.tar.gz | tar xvz -C "/usr/src/php/ext/msgpack" --strip 1; \
    docker-php-ext-install msgpack;

RUN docker-php-ext-install pcntl
RUN docker-php-ext-install shmop
RUN docker-php-ext-install sysvmsg sysvsem sysvshm
RUN docker-php-ext-install xmlrpc

#RUN apt update && apt install -y --no-install-recommends libxslt-dev
#RUN apt install -y --no-install-recommends libmagickwand-dev

RUN mkdir -p /usr/src/php/ext/imagick; \
    curl -fsSL https://github.com/Imagick/imagick/archive/refs/tags/3.4.4RC2.tar.gz | tar xvz -C "/usr/src/php/ext/imagick" --strip 1; \
    docker-php-ext-install imagick;

RUN docker-php-ext-install sockets

#Copy opcache config file
COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini

#Enable apache2 modules
#RUN a2enmod rewrite ssl

#Copy php configuracion production
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

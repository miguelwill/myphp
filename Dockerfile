FROM php:5.6-apache-stretch
MAINTAINER miguelwill@gmail.com

#ENV Variables for OPCACHE
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="1" \
    PHP_OPCACHE_MAX_ACCELERATED_FILES="10000" \
    PHP_OPCACHE_MEMORY_CONSUMPTION="192" \
    PHP_OPCACHE_MAX_WASTED_PERCENTAGE="10" 


RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list && \
	export DEBIAN_FRONTEND=noninteractive && \
	apt-get update -y && apt-get upgrade -y --force-yes \
        && apt-get install -y --no-install-recommends --force-yes libxml2-dev zlib1g-dev zip imagemagick pdftk libpng-dev ssmtp \
        && apt-get clean -y

#add file /etc/ssmtp/ssmtp.conf for smtp sending

#Install modules in php
RUN docker-php-ext-install mysqli pdo pdo_mysql opcache zip soap mbstring
RUN docker-php-ext-install mysql

#Copy opcache config file
COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# extra modules

RUN  apt-get install -y --no-install-recommends --force-yes libz-dev curl libzip-dev unzip  freetds-common freetds-dev \
	unixodbc unixodbc-dev libodbc1 odbcinst1debian2 libpq-dev git tdsodbc libaio-dev \
        && apt-get clean -y

RUN ln -s /usr/lib/x86_64-linux-gnu/libsybdb.a /usr/lib/libsybdb.a \
	&& ln -s /usr/lib/x86_64-linux-gnu/libsybdb.so /usr/lib/libsybdb.so 

RUN docker-php-ext-install pdo_dblib 
RUN docker-php-ext-install dba 
RUN docker-php-ext-install exif
RUN docker-php-ext-install gettext
RUN docker-php-ext-install mysql
RUN docker-php-ext-install pcntl
RUN docker-php-ext-install shmop
RUN docker-php-ext-install sockets
RUN docker-php-ext-install sysvmsg sysvsem sysvshm
RUN docker-php-ext-install wddx 
RUN docker-php-ext-install xmlrpc
RUN docker-php-ext-install intl

RUN apt-get update && apt-get install -y libpng-dev libjpeg-dev libfreetype6-dev --no-install-recommends && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd \
        --enable-gd-native-ttf \
        --with-freetype-dir=/usr/include/freetype2 \
        --with-png-dir=/usr/include \
        --with-jpeg-dir=/usr/include \
       && docker-php-ext-install gd \
	&& docker-php-ext-enable gd

RUN apt-get update && apt-get install -y libmagickwand-dev --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y libgraphicsmagick1-dev libmagickcore-dev  libmagickwand-6-headers --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN ln -s /usr/lib/x86_64-linux-gnu/ImageMagick-6.9.7/bin-q16/MagickWand-config /usr/bin/MagickWand-config && \
    ln -s /usr/lib/x86_64-linux-gnu/ImageMagick-6.9.7/bin-q16/Wand-config /usr/bin/Wand-config && \
    ln -s /usr/lib/x86_64-linux-gnu/ImageMagick-6.9.7/bin-q16/Magick-config /usr/bin/Magick-config

RUN mkdir -p /usr/src/php/ext/imagick; \
    curl -fsSL https://github.com/Imagick/imagick/archive/refs/tags/3.2.0RC1.tar.gz | tar xvz -C "/usr/src/php/ext/imagick" --strip 1; \
    docker-php-ext-install imagick;

#install timezonedb
RUN docker-php-source extract \
    && pecl bundle -d /usr/src/php/ext timezonedb \
    && docker-php-ext-configure timezonedb \
    && docker-php-ext-install -j$(nproc) timezonedb \
    && docker-php-source delete


#Enable apache2 modules
RUN a2enmod rewrite ssl

#Copy php configuracion production
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

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
RUN docker-php-ext-install mysqli pdo pdo_mysql opcache zip soap gd mbstring
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

#Enable apache2 modules
RUN a2enmod rewrite ssl

#Copy php configuracion production
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

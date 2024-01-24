FROM php:7.4-cli-bullseye
MAINTAINER miguelwill@gmail.com

#ENV Variables for OPCACHE
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="1" \
    PHP_OPCACHE_MAX_ACCELERATED_FILES="10000" \
    PHP_OPCACHE_MEMORY_CONSUMPTION="192" \
    PHP_OPCACHE_MAX_WASTED_PERCENTAGE="10" 


#RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list && \
RUN	export DEBIAN_FRONTEND=noninteractive && \
	apt-get update -y &&\
        apt-get install -y --no-install-recommends --force-yes libxml2-dev zlib1g-dev zip imagemagick \
	pdftk libpng-dev libz-dev curl libzip-dev unzip  freetds-common freetds-dev \
	libpq-dev git  libaio-dev libonig-dev \
        && apt-get clean -y

#Install modules in php
RUN docker-php-ext-install mysqli pdo pdo_mysql opcache zip soap gd mbstring
RUN docker-php-ext-install tokenizer bcmath calendar sysvmsg sysvsem sysvshm

#install mail and ssmtp
RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get update -y &&\
	apt-get install -y --no-install-recommends --force-yes bsd-mailx ssmtp 

#Copy opcache config file
COPY conf.ini /usr/local/etc/php/conf.d/conf.ini
COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini

#Enable apache2 modules disable on cli
#RUN a2enmod rewrite ssl

#Copy php configuracion production
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

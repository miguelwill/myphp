FROM php:5.3.29-apache
MAINTAINER miguelwill@gmail.com

#ENV Variables for OPCACHE
#ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="1" \
#    PHP_OPCACHE_MAX_ACCELERATED_FILES="10000" \
#    PHP_OPCACHE_MEMORY_CONSUMPTION="192" \
#    PHP_OPCACHE_MAX_WASTED_PERCENTAGE="10"

#Install modules in php
#RUN docker-php-ext-install mysqli pdo pdo_mysql opcache mysql

#Copy opcache config file
#COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini

#Enable apache2 modules
#RUN a2enmod rewrite

#install dev packages
RUN export DEBIAN_FRONTEND=noninteractive && \
  apt update && \
  apt-get -y --force-yes upgrade && \
  apt install -y --no-install-recommends apache2-dev libmysqlclient-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

#prepare apache2 mod mysql auth
COPY mod_auth_mysql-3.0.0 /usr/src/mod_auth_mysql-3.0.0

#compile mod mysql auth
RUN cd /usr/src/mod_auth_mysql-3.0.0 && \
  apxs2 -c -L/usr/lib/mysql -I/usr/include/mysql -lmysqlclient -lm -lz mod_auth_mysql.c && \
  apxs2 -i mod_auth_mysql.la
RUN echo "LoadModule mysql_auth_module /usr/lib/apache2/modules/mod_auth_mysql.so" > /etc/apache2/mods-available/auth_mysql.load && \
  a2enmod auth_mysql rewrite


#Copy php configuracion production
#RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

FROM php:5.4-apache
MAINTAINER miguelwill@gmail.com



#install dev packages
RUN export DEBIAN_FRONTEND=noninteractive && \
  echo "deb http://archive.debian.org/debian jessie main contrib non-free" > /etc/apt/sources.list && \
  apt update && \
  apt-get -y --force-yes upgrade

RUN export DEBIAN_FRONTEND=noninteractive && \
  apt-get install -y --no-install-recommends --force-yes apache2-dev libmysqlclient-dev ssmtp libxml2-dev zlib1g-dev zip imagemagick pdftk libpng-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

#add file /etc/ssmtp/ssmtp.conf for smtp sending

# extra modules
RUN  apt-get update -y && apt-get install -y --no-install-recommends --force-yes libz-dev curl libzip-dev unzip  freetds-common freetds-dev \
        unixodbc unixodbc-dev libodbc1 odbcinst1debian2 libpq-dev git tdsodbc libaio-dev \
        && apt-get clean -y

RUN ln -s /usr/lib/x86_64-linux-gnu/libsybdb.a /usr/lib/libsybdb.a \
        && ln -s /usr/lib/x86_64-linux-gnu/libsybdb.so /usr/lib/libsybdb.so

#Install modules in php

RUN docker-php-ext-install pdo_dblib
RUN docker-php-ext-install mysqli 
RUN docker-php-ext-install mysql 
RUN docker-php-ext-install pdo
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install zip 
RUN docker-php-ext-install soap 
RUN docker-php-ext-install gd 
RUN docker-php-ext-install mbstring

RUN docker-php-ext-install dba
RUN docker-php-ext-install exif
RUN docker-php-ext-install gettext
RUN docker-php-ext-install pcntl
RUN docker-php-ext-install shmop
RUN docker-php-ext-install sockets
RUN docker-php-ext-install sysvmsg sysvsem sysvshm
RUN docker-php-ext-install wddx
RUN docker-php-ext-install xmlrpc

RUN apt-get install -y --force-yes --no-install-recommends libicu-dev

RUN docker-php-ext-install intl

#Enable apache2 modules
RUN a2enmod rewrite ssl

#prepare apache2 mod mysql auth
COPY mod_auth_mysql-3.0.0 /usr/src/mod_auth_mysql-3.0.0

#compile mod mysql auth
RUN cd /usr/src/mod_auth_mysql-3.0.0 && \
  apxs2 -c -L/usr/lib/mysql -I/usr/include/mysql -lmysqlclient -lm -lz mod_auth_mysql.c && \
  apxs2 -i mod_auth_mysql.la
RUN echo "LoadModule mysql_auth_module /usr/lib/apache2/modules/mod_auth_mysql.so" > /etc/apache2/mods-available/auth_mysql.load && \
  a2enmod auth_mysql

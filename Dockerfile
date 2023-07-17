FROM php:5.6-cli-stretch
MAINTAINER miguelwill@gmail.com

#ENV Variables for OPCACHE
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="1" \
    PHP_OPCACHE_MAX_ACCELERATED_FILES="10000" \
    PHP_OPCACHE_MEMORY_CONSUMPTION="192" \
    PHP_OPCACHE_MAX_WASTED_PERCENTAGE="10" 


RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list && \
	export DEBIAN_FRONTEND=noninteractive && \
	apt-get update -y &&\
        apt-get install -y --no-install-recommends --force-yes libxml2-dev zlib1g-dev zip imagemagick \
	pdftk libpng-dev libz-dev curl libzip-dev unzip  freetds-common freetds-dev \
	unixodbc unixodbc-dev libodbc1 odbcinst1debian2 libpq-dev git tdsodbc libaio-dev pdftk \
        && apt-get clean -y

#Install modules in php
RUN docker-php-ext-install mysqli pdo pdo_mysql opcache zip soap gd mbstring



# Download oracle packages and install OCI8
COPY instantclient-basic-linuxx64.zip /tmp/instantclient-basic-linuxx64.zip
COPY instantclient-sdk-linuxx64.zip /tmp/instantclient-sdk-linuxx64.zip

RUN unzip /tmp/instantclient-sdk-linuxx64.zip -d /usr/lib/oracle/ \
    && rm /tmp/instantclient-sdk-linuxx64.zip \
    && unzip /tmp/instantclient-basic-linuxx64.zip -d /usr/lib/oracle/ \
    && rm /tmp/instantclient-basic-linuxx64.zip \
    && echo /usr/lib/oracle/instantclient_21_10 > /etc/ld.so.conf.d/oracle-instantclient.conf \
    && ldconfig

ENV LD_LIBRARY_PATH /usr/lib/oracle/instantclient_21_10

# Install php oci8 module with path of instantclient
RUN docker-php-ext-configure oci8 \
	--with-oci8=instantclient,/usr/lib/oracle/instantclient_21_10 
RUN docker-php-ext-install oci8 

	
RUN ln -s /usr/lib/x86_64-linux-gnu/libsybdb.a /usr/lib/libsybdb.a \
	&& ln -s /usr/lib/x86_64-linux-gnu/libsybdb.so /usr/lib/libsybdb.so 

RUN mkdir /usr/local/incl &&\
	ln -s /usr/include/sqlext.h  /usr/local/incl/sqlext.h


# oracle oci php module
RUN docker-php-ext-configure pdo_odbc \
	--with-pdo-odbc=unixODBC,/usr

RUN docker-php-ext-install pdo_odbc

RUN set -x \
    && docker-php-source extract \
    && cd /usr/src/php/ext/odbc \
    && phpize \
    && sed -ri 's@^ *test +"\$PHP_.*" *= *"no" *&& *PHP_.*=yes *$@#&@g' configure \
    && ./configure --with-unixODBC=shared,/usr \
    && docker-php-ext-install odbc \
    && docker-php-source delete

	
RUN docker-php-ext-install pdo_dblib 
RUN docker-php-ext-install tokenizer wddx bcmath calendar sysvmsg sysvsem sysvshm

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

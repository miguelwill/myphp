FROM php:8.4-apache-trixie
LABEL maintainer="miguelwill@gmail.com"

# Variables de entorno para OPcache
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="1" \
    PHP_OPCACHE_MAX_ACCELERATED_FILES="10000" \
    PHP_OPCACHE_MEMORY_CONSUMPTION="192" \
    PHP_OPCACHE_MAX_WASTED_PERCENTAGE="10"

# 1. Habilitar módulos de Apache (rewrite y ssl)
RUN a2enmod rewrite ssl

# 2. Dependencias del sistema y librerías de base de datos
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    unzip \
    zip \
    curl \
    pkg-config \
    zlib1g-dev \
    libonig-dev \
    libaio1t64 \
    libaio-dev \
    libxml2-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    freetds-dev \
    freetds-bin \
    freetds-common \
    tdsodbc \
    unixodbc \
    unixodbc-dev \
    libpq-dev \
    imagemagick \
    pdftk-java \
    msmtp \
    msmtp-mta \
    bsd-mailx \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 3. Descomprimir e instalar Oracle Instant Client + Symlink de libaio
COPY instantclient-basic-linuxx64.zip /tmp/instantclient-basic.zip
COPY instantclient-sdk-linuxx64.zip /tmp/instantclient-sdk.zip

RUN ln -s /usr/lib/x86_64-linux-gnu/libaio.so.1t64 /usr/lib/x86_64-linux-gnu/libaio.so.1 2>/dev/null \
    || ln -s /usr/lib/x86_64-linux-gnu/libaio.so /usr/lib/x86_64-linux-gnu/libaio.so.1 2>/dev/null \
    && ldconfig

RUN mkdir -p /usr/lib/oracle \
    && unzip -q /tmp/instantclient-basic.zip -d /usr/lib/oracle/ \
    && unzip -q /tmp/instantclient-sdk.zip -d /usr/lib/oracle/ \
    && rm /tmp/instantclient-basic.zip /tmp/instantclient-sdk.zip \
    && IC_DIR=$(find /usr/lib/oracle -maxdepth 1 -type d -name "instantclient_*" | head -n 1) \
    && ln -s "$IC_DIR" /usr/lib/oracle/instantclient \
    && echo "/usr/lib/oracle/instantclient" > /etc/ld.so.conf.d/oracle-instantclient.conf \
    && ldconfig

ENV LD_LIBRARY_PATH="/usr/lib/oracle/instantclient"
ENV ORACLE_HOME="/usr/lib/oracle/instantclient"

# 4. Enlaces simbólicos para unixODBC y FreeTDS
RUN ln -s /usr/include/sqlext.h /usr/local/include/sqlext.h 2>/dev/null || true \
    && ln -s /usr/lib/x86_64-linux-gnu/libodbc.so /usr/lib/libodbc.so 2>/dev/null || true \
    && ln -s /usr/lib/x86_64-linux-gnu/libsybdb.so /usr/lib/libsybdb.so 2>/dev/null || true

# 5. Configurar y compilar extensiones Core
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure pdo_odbc --with-pdo-odbc=unixODBC,/usr \
    && docker-php-ext-configure pdo_dblib --with-pdo-dblib=/usr \
    && docker-php-ext-install -j$(nproc) \
        bcmath \
        calendar \
        gd \
        mbstring \
        mysqli \
        opcache \
        pdo \
        pdo_dblib \
        pdo_mysql \
        pdo_odbc \
        soap \
        sysvmsg \
        sysvsem \
        sysvshm \
        zip

# 6. Compilar e instalar ODBC nativo con unixODBC (evitando Adabas D)
RUN docker-php-source extract \
    && cd /usr/src/php/ext/odbc \
    && phpize \
    && sed -ri 's@^ *test +"\$PHP_.*" *= *"no" *&& *PHP_.*=yes *$@#&@g' configure \
    && ./configure --with-unixODBC=shared,/usr \
    && make -j$(nproc) \
    && make install \
    && docker-php-ext-enable odbc \
    && docker-php-source delete

# 7. Extensiones PECL: Oracle (OCI8, PDO_OCI) y timezonedb
RUN echo "instantclient,/usr/lib/oracle/instantclient" | pecl install oci8 \
    && echo "instantclient,/usr/lib/oracle/instantclient" | pecl install pdo_oci \
    && pecl install timezonedb \
    && docker-php-ext-enable oci8 pdo_oci timezonedb \
    && rm -rf /tmp/pear

# 8. Variables de entorno de Oracle para el proceso Apache
RUN echo "export LD_LIBRARY_PATH=/usr/lib/oracle/instantclient" >> /etc/apache2/envvars \
    && echo "export ORACLE_HOME=/usr/lib/oracle/instantclient" >> /etc/apache2/envvars

# 9. Archivos de configuración
COPY conf.ini /usr/local/etc/php/conf.d/conf.ini
COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Puerto HTTP y HTTPS expuestos
EXPOSE 80 443

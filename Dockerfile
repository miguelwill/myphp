FROM php:8.4-apache-trixie
LABEL maintainer="miguelwill@gmail.com"

# Variables de entorno para OPcache
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="1" \
    PHP_OPCACHE_MAX_ACCELERATED_FILES="10000" \
    PHP_OPCACHE_MEMORY_CONSUMPTION="192" \
    PHP_OPCACHE_MAX_WASTED_PERCENTAGE="10" \
    APACHE_RPAF_PROXY_IPS="172.16.0.1"

# 1. Habilitar módulos de Apache
RUN a2enmod rewrite ssl headers

# 2. Paquetes del sistema, configuración y compilación de módulos PHP en una sola capa limpia
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    imagemagick \
    libcurl4-openssl-dev \
    libfreetype6-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libonig-dev \
    libpng-dev \
    libxml2-dev \
    libxslt1-dev \
    libzip-dev \
    msmtp \
    msmtp-mta \
    p7zip-full \
    pdftk-java \
    pkg-config \
    zip \
    zlib1g-dev \
    # Configurar extensiones que requieren flags específicos
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    # Compilar e instalar todas las extensiones nativas en paralelo
    && docker-php-ext-install -j$(nproc) \
        calendar \
        curl \
        exif \
        gd \
        iconv \
        intl \
        mbstring \
        mysqli \
        opcache \
        pcntl \
        pdo \
        pdo_mysql \
        shmop \
        soap \
        sysvmsg \
        sysvsem \
        sysvshm \
        xml \
        xsl \
        zip \
    # Compilar extensiones PECL compatibles con PHP 8.4
    && pecl install msgpack channel://pecl.php.net/xmlrpc-1.0.0RC3 \
    && docker-php-ext-enable msgpack xmlrpc \
    # Limpieza para reducir el tamaño final de la imagen
    && apt-get purge -y --auto-remove pkg-config \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/pear /usr/src/php/ext/msgpack

# 3. Archivos de configuración
COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

EXPOSE 80 443

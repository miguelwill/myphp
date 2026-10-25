FROM php:8.4-fpm-trixie
LABEL maintainer="NN <miguelwill@gmail.com>"

# Variables de entorno para OPcache
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="1" \
    PHP_OPCACHE_MAX_ACCELERATED_FILES="10000" \
    PHP_OPCACHE_MEMORY_CONSUMPTION="192" \
    PHP_OPCACHE_MAX_WASTED_PERCENTAGE="10"

# Dependencias del sistema (usando los repositorios limpios de Trixie)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    vim \
    zip \
    libzip-dev \
    libxml2-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxslt1-dev \
    libmagickwand-dev \
    pdftk-java \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Extensiones nativas del core en una sola capa paralela
RUN docker-php-ext-install -j$(nproc) \
    bcmath \
    calendar \
    exif \
    gd \
    gettext \
    mbstring \
    mysqli \
    opcache \
    pcntl \
    pdo \
    pdo_mysql \
    shmop \
    soap \
    sockets \
    sysvmsg \
    sysvsem \
    sysvshm \
    xsl \
    zip

# Extensiones PECL compatibles con PHP 8.4
# (Se compilan e instalan con dependencias temporales de build para no inflar la imagen)
RUN pecl install timezonedb igbinary msgpack imagick \
    && docker-php-ext-enable timezonedb igbinary msgpack imagick \
    && rm -rf /tmp/pear

# Archivos de configuración
COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

FROM php:7.3-cli-bullseye
MAINTAINER miguelwill@gmail.com

#install dev packages
RUN export DEBIAN_FRONTEND=noninteractive && \
  apt update && \
  apt-get -y upgrade && \
  apt install -y --no-install-recommends libxml2-dev zlib1g-dev libzip4 libzip-dev zip pdftk cron wget jq curl && \
  apt clean && \
  rm -rf /var/lib/apt/lists/*

#Install modules in php
RUN docker-php-ext-install mysqli pdo pdo_mysql zip soap json


#Copy php configuracion production
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY cron-entrypoint.sh /cron-entrypoint.sh
RUN chmod +x /cron-entrypoint.sh
ENTRYPOINT ["/cron-entrypoint.sh"]

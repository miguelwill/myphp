FROM php:7.4-apache
MAINTAINER miguelwill@gmail.com
RUN docker-php-ext-install mysqli pdo pdo_mysql
RUN a2enmod rewrite ssl

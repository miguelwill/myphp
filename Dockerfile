FROM php:5.3.29-apache
MAINTAINER miguelwill@gmail.com

#install dev packages
RUN export DEBIAN_FRONTEND=noninteractive && \
  echo "deb http://archive.debian.org/debian jessie main contrib non-free" > /etc/apt/sources.list && \
  apt update

RUN  apt install -y --no-install-recommends --force-yes apache2-dev libmysqlclient-dev libpng-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

COPY apache2.conf /etc/apache2/apache2.conf
RUN mkdir -m755 /var/run/apache2

#prepare apache2 mod mysql auth
COPY mod_auth_mysql-3.0.0 /usr/src/mod_auth_mysql-3.0.0

#compile mod mysql auth
RUN cd /usr/src/mod_auth_mysql-3.0.0 && \
  apxs2 -c -L/usr/lib/mysql -I/usr/include/mysql -lmysqlclient -lm -lz mod_auth_mysql.c && \
  apxs2 -i mod_auth_mysql.la
RUN echo "LoadModule mysql_auth_module /usr/lib/apache2/modules/mod_auth_mysql.so" > /etc/apache2/mods-available/auth_mysql.load && \
  a2enmod auth_mysql rewrite ssl

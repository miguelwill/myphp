# Myphp
php and apache with extra modules

modules in v8.1 (apache 2.4 )
mbstring
gd
mysqli
pdo
pdo_mysql
opcache
zip
soap
xml
curl
memcached (only ext, for external process)

Based on base image php:8.1-apache-bullseye
has the necessary packages installed for the required modules

# Memcached

the memcached module is based on version 3.2, compatible with php 8.1

# Mpm_prefork

the mpm_prefork.conf file was added to increase the MaxSpareServers value from the default value (10) to 150.

this image was created for use with websites like wordpress or joomla that require specific modules and specific versions.

# OPCache
OPcache enabled

image in docker-hub : https://hub.docker.com/r/miguelwill/myphp

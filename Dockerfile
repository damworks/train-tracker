FROM php:8.3-fpm-alpine

# Installazione dipendenze di sistema ed estensioni PHP per Symfony
RUN apk add --no-cache icu-dev zip libzip-dev git \
    && docker-php-ext-install pdo_mysql opcache intl zip

# Copia Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copia il codice della webapp
COPY . .

# Disabilitiamo gli script automatici durante la build con --no-scripts
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-dev --no-scripts --optimize-autoloader

# Permessi sulle cartelle di cache e log
RUN chown -R www-data:www-data var

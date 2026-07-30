FROM php:8.3-fpm-alpine

# Installer ufficiale per estensioni PHP
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

# Installiamo tutte le estensioni comuni per Symfony
RUN install-php-extensions pdo_mysql opcache intl zip dom xml mbstring

# Copia Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . .

ENV COMPOSER_ALLOW_SUPERUSER=1

# Aggiunto -vvv per stampare l'errore esatto e rimosso --optimize-autoloader
RUN composer install --no-dev --no-scripts -vvv

RUN mkdir -p var/cache var/log && chown -R www-data:www-data var
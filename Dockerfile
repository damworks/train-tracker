# ==========================================
# STAGE 1: Download dipendenze con Composer
# ==========================================
FROM composer:2 AS vendor

WORKDIR /app

COPY composer.json composer.lock ./

RUN composer install \
    --no-dev \
    --no-scripts \
    --no-autoloader \
    --ignore-platform-reqs

COPY . .

RUN composer dump-autoload --no-dev --optimize

# ==========================================
# STAGE 2: Runtime PHP 8.4 FPM
# ==========================================
FROM php:8.4-fpm-alpine

# Installer estensioni PHP
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions pdo_mysql opcache intl zip dom xml mbstring

WORKDIR /var/www/html

COPY --from=vendor /app /var/www/html

RUN mkdir -p var/cache var/log && chown -R www-data:www-data var
# ==========================================
# STAGE 1: Download delle dipendenze con Composer ufficiale
# ==========================================
FROM composer:2 AS vendor

WORKDIR /app

COPY composer.json composer.lock ./

# Installiamo i pacchetti senza dev e senza script
RUN composer install \
    --no-dev \
    --no-scripts \
    --no-autoloader \
    --ignore-platform-reqs

COPY . .

# Generiamo l'autoloader finale
RUN composer dump-autoload --no-dev --optimize

# ==========================================
# STAGE 2: Immagine PHP FPM di Produzione
# ==========================================
FROM php:8.3-fpm-alpine

# Installatore estensioni PHP
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions pdo_mysql opcache intl zip dom xml mbstring

WORKDIR /var/www/html

# Copiamo il codice e le dipendenze già pronte dallo STAGE 1
COPY --from=vendor /app /var/www/html

# Creazione cartelle var e permessi
RUN mkdir -p var/cache var/log && chown -R www-data:www-data var
FROM php:8.3-fpm-alpine

# 1. Pacchetti di sistema essenziali per Alpine (unzip e git servono a Composer)
RUN apk add --no-cache git unzip ca-certificates

# 2. Installer ufficiale per le estensioni PHP di Symfony
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions pdo_mysql opcache intl zip dom xml mbstring

# 3. Copia dell'eseguibile Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# 4. Copia del codice sorgente
COPY . .

ENV COMPOSER_ALLOW_SUPERUSER=1

# 5. Installazione delle dipendenze senza script post-installazione (che richiederebbero il DB attivo)
RUN composer install --no-dev --no-scripts --optimize-autoloader

# 6. Creazione delle cartelle di runtime e permessi per Nginx/PHP
RUN mkdir -p var/cache var/log && chown -R www-data:www-data var
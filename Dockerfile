FROM php:8.3-fpm-alpine

# Strumento ufficiale per installare estensioni PHP in Docker senza impazzire con Alpine
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

# Installazione pulita delle estensioni richieste da Symfony
RUN install-php-extensions pdo_mysql opcache intl zip

# Copia Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copiamo prima solo i file di configurazione delle dipendenze per sfruttare la cache Docker
COPY composer.json composer.lock ./

ENV COMPOSER_ALLOW_SUPERUSER=1

# Installazione pacchetti senza script post-installazione
RUN composer install --no-dev --no-scripts --optimize-autoloader

# Copia tutto il sorgente del progetto
COPY . .

# Creazione cartelle var e gestione dei permessi per www-data
RUN mkdir -p var/cache var/log && chown -R www-data:www-data var
FROM php:8.3-fpm-alpine

# Installer ufficiale per estensioni PHP
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

# Installazione estensioni fondamentali per Symfony (incluse dom, xml e mbstring)
RUN install-php-extensions pdo_mysql opcache intl zip dom xml mbstring

# Copia l'eseguibile Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copiamo il codice sorgente (inclusa la cartella src/ necessaria per la mappa delle classi)
COPY . .

ENV COMPOSER_ALLOW_SUPERUSER=1

# Installazione dei pacchetti SENZA script post-installazione che richiederebbero il DB
RUN composer install --no-dev --no-scripts --optimize-autoloader

# Creazione cartelle di cache/log e gestione permessi per Nginx/PHP
RUN mkdir -p var/cache var/log && chown -R www-data:www-data var
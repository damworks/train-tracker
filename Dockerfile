FROM php:8.3-fpm-alpine

# Installazione librerie di sistema per compilare le estensioni PHP
RUN apk add --no-cache \
    icu-dev \
    libzip-dev \
    oniguruma-dev \
    git \
    unzip

# Installazione di tutte le estensioni PHP richieste da Symfony
RUN docker-php-ext-install \
    pdo_mysql \
    opcache \
    intl \
    zip \
    mbstring \
    ctype \
    iconv

# Copia dell'eseguibile di Composer dalla sua immagine ufficiale
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copiamo prima solo i manifest delle dipendenze
COPY composer.json composer.lock ./

# Permettiamo a Composer di girare da root nel container
ENV COMPOSER_ALLOW_SUPERUSER=1

# Installazione dei pacchetti SENZA eseguire script che richiedono il DB attivo
RUN composer install --no-dev --no-scripts --optimize-autoloader

# Ora copiamo il resto del codice sorgente della webapp
COPY . .

# Creazione cartelle var/cache e var/log con i giusti permessi
RUN mkdir -p var/cache var/log && chown -R www-data:www-data var
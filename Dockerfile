# ==================== СТАДИЯ 1: COMPOSER ====================
FROM composer:latest AS composer

# ==================== СТАДИЯ 2: БАЗОВЫЙ ОБРАЗ ====================
FROM php:8.3-fpm AS base

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN apt-get update && apt-get install -y \
    libpq-dev \
    libzip-dev \
    zip \
    unzip \
    libicu-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    git \
    libonig-dev \
    procps \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install -j$(nproc) \
    pdo_pgsql \
    pgsql \
    intl \
    zip \
    opcache \
    bcmath \
    mbstring \
    xml \
    dom \
    curl \
    fileinfo

COPY --from=composer /usr/bin/composer /usr/bin/composer

RUN usermod -u ${USER_ID} www-data && groupmod -g ${GROUP_ID} www-data

WORKDIR /var/www

# ==================== СТАДИЯ 3: DEVELOPMENT ====================
FROM base AS dev

# Конфиги
COPY ./docker/php/php.ini /usr/local/etc/php/php.ini

# Код копируется, но будет перекрыт bind mount в docker-compose
COPY app/ .

# Все зависимости
RUN composer install --no-interaction

RUN mkdir -p var/cache var/log \
    && chown -R www-data:www-data var public \
    && chmod -R 777 var

USER www-data
CMD ["php-fpm"]

# ==================== СТАДИЯ 4: PRODUCTION BUILDER ====================
FROM base AS prod-builder

COPY app/ .

# Только production-зависимости
RUN composer install \
    --no-dev \
    --no-interaction \
    --optimize-autoloader \
    --no-scripts

# Прогрев кэша
RUN php bin/console cache:clear --env=prod --no-debug \
    && php bin/console cache:warmup --env=prod \
    && chown -R www-data:www-data var public

# ==================== СТАДИЯ 5: PRODUCTION RUNTIME ====================
FROM base AS prod

# Только готовый код из builder
COPY --from=prod-builder /var/www /var/www

# Production-конфиг PHP
COPY ./docker/php/php.prod.ini /usr/local/etc/php/php.ini

RUN chown -R www-data:www-data var public

USER www-data

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD pgrep php-fpm || exit 1

CMD ["php-fpm"]
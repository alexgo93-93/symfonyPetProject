# ==================== БАЗОВЫЙ ОБРАЗ ====================
FROM php:8.3-fpm

# ==================== АРГУМЕНТЫ СБОРКИ ====================
ARG APP_ENV=dev
ARG USER_ID=1000
ARG GROUP_ID=1000

# ==================== СИСТЕМНЫЕ ЗАВИСИМОСТИ ====================
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
    && rm -rf /var/lib/apt/lists/*

# ==================== PHP РАСШИРЕНИЯ ====================
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

# ==================== COMPOSER ====================
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# ==================== ПОЛЬЗОВАТЕЛЬ ====================
RUN usermod -u ${USER_ID} www-data && groupmod -g ${GROUP_ID} www-data

# ==================== РАБОЧАЯ ДИРЕКТОРИЯ ====================
WORKDIR /var/www

# ==================== КОПИРОВАНИЕ КОДА ====================
# Копируем ВСЁ содержимое папки app (где лежит composer.json)
COPY app/ .

# ==================== УСТАНОВКА ЗАВИСИМОСТЕЙ ====================
# Теперь composer.json точно есть в текущей директории
RUN if [ "$APP_ENV" = "prod" ]; then \
        composer install --no-dev --no-interaction --optimize-autoloader --no-scripts; \
    else \
        composer install --no-interaction; \
    fi

# ==================== ПРАВА ====================
RUN mkdir -p var/cache var/log \
    && chown -R www-data:www-data var public \
    && chmod -R 777 var

# ==================== ПОЛЬЗОВАТЕЛЬ ====================
USER www-data

# ==================== ЗАПУСК ====================
EXPOSE 9000
CMD ["php-fpm"]
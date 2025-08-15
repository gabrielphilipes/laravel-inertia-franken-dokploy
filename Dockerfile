# --- Node build (assets Vite) ---
FROM node:20-alpine AS nodebuild
WORKDIR /app
COPY package*.json vite.config.* ./
RUN npm ci
COPY resources ./resources
RUN npm run build

# --- Composer (deps PHP) ---
FROM composer:2 AS composerbuild
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --prefer-dist --no-interaction --no-progress

# --- FrankenPHP runtime ---
FROM dunglas/frankenphp:latest-php8.3
WORKDIR /app

# PHP config (produção)
RUN cp $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini

# Extensões que ajudam no dia a dia
RUN install-php-extensions \
    pdo_pgsql pdo_mysql intl zip opcache redis

# Copia app
COPY . .
# Vendor e assets prontos p/ produção
COPY --from=composerbuild /app/vendor ./vendor
COPY --from=nodebuild    /app/public/build ./public/build

# Caddyfile (prod)
COPY docker/Caddyfile /etc/frankenphp/Caddyfile

ENV APP_ENV=production \
    APP_DEBUG=false

# FrankenPHP escuta :80 por padrão; Dokploy/Traefik vai rotear pra cá
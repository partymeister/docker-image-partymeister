# Version 2.1.3

FROM php:8.2-fpm

RUN apt-get install -y curl
RUN curl -fsSL https://deb.nodesource.com/setup_23.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    libpng-dev \
    libjpeg-dev \
    libgd-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    cron \
    imagemagick \
    ffmpeg \
    wget \
    gnupg \
    supervisor \
    htop \
    libmagickwand-dev \
    jpegoptim \
    optipng \
    pngquant \
    gifsicle \
    libavif-bin \
    libwebp-dev \
    webp \
    nodejs

# Install PHP extensions
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp && docker-php-ext-install pdo_mysql mysqli mbstring exif pcntl bcmath gd zip soap intl

# Install redis extension for php
RUN pecl install redis && docker-php-ext-enable redis

# Install imagick extension for php
RUN pecl install imagick && docker-php-ext-enable imagick

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN npm install -g pm2

RUN npm install -g playwright
RUN npx playwright install-deps
RUN npx playwright install chromium

# Clean installation
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh /var/www/entrypoint.sh

# Install depedencies, set .env file, clear all caches and start fpm
ENTRYPOINT /var/www/entrypoint.sh

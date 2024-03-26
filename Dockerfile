FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
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
    webp

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp && docker-php-ext-install pdo_mysql mysqli mbstring exif pcntl bcmath gd zip soap intl

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install redis extension for php
RUN pecl install redis && docker-php-ext-enable redis

# Install imagick extension for php
RUN pecl install imagick && docker-php-ext-enable imagick

# Get chromium and chromium driver
RUN apt install -y chromium chromium-driver

# Clean installation
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install depedencies, set .env file, clear all caches and start fpm
CMD php-fpm

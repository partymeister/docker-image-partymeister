FROM php:8.2-fpm

# Install system dependencies
RUN apt update && apt upgrade -y && apt-get install -y \
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
    htop

# Install PHP extensions
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg && docker-php-ext-install pdo_mysql mysqli mbstring exif pcntl bcmath gd zip soap intl

# Install redis extension for php
RUN pecl install redis && docker-php-ext-enable redis

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Get chromium and chromium driver
RUN apt install -y chromium chromium-driver

# Clean installation
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install depedencies, set .env file, clear all caches and start fpm
CMD php-fpm

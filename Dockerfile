# ── Build PHP extensions ─────────────────────
FROM php:8.4-fpm-bookworm AS builder

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    libpng-dev libjpeg-dev libgd-dev libonig-dev libxml2-dev \
    libzip-dev libmagickwand-dev libwebp-dev \
    && docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install pdo_mysql mysqli mbstring exif pcntl bcmath gd zip soap intl \
    && pecl install redis imagick \
    && docker-php-ext-enable redis imagick

# ── Production ───────────────────────────────
FROM php:8.4-fpm-bookworm AS production

COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

# Node.js 22 LTS via nodesource
RUN apt-get update && apt-get install -y --no-install-recommends curl gnupg \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get remove --purge -y gnupg \
    && apt-get autoremove -y

# Runtime dependencies + Node
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    git curl zip unzip cron imagemagick ffmpeg wget supervisor \
    jpegoptim optipng pngquant gifsicle libavif-bin webp nodejs \
    libpng16-16 libjpeg62-turbo libgd3 libonig5 libxml2 libzip4 \
    libmagickwand-6.q16-6 libwebp7 ca-certificates \
    && apt-get remove --purge -y \
        linux-libc-dev \
        libc6-dev \
        gcc \
        g++ \
        cpp \
        dpkg-dev \
        make \
    && apt-get autoremove -y \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# PM2 + Playwright with Chromium
RUN npm install -g pm2 playwright \
    && npx playwright install-deps \
    && npx playwright install chromium \
    && rm -rf /root/.cache/node

WORKDIR /var/www
COPY ./entrypoint.sh /var/www/entrypoint.sh
RUN chmod +x /var/www/entrypoint.sh
ENTRYPOINT ["/var/www/entrypoint.sh"]

# ── Dev ──────────────────────────────────────
FROM production AS dev

RUN apt-get update && apt-get install -y --no-install-recommends \
        gcc make autoconf linux-libc-dev libc6-dev \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && apt-get remove --purge -y gcc make autoconf linux-libc-dev libc6-dev \
    && apt-get autoremove -y \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY ./xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug-config.ini

COPY ./entrypoint.dev.sh /var/www/entrypoint.sh
RUN chmod +x /var/www/entrypoint.sh

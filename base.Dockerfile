# Base Container for the Laravel Cloud Run
FROM php:8.1.4-fpm

# Arguments defined in docker-compose build args
ARG user=www-data
ARG uid=33
ARG project=yoflo
# Update Base System Dependencies
RUN apt-get update && apt-get upgrade -y

# Install system dependencies
RUN apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# Install docker-php extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install php composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
# Install grpc and enable it in PHP for Composer to install the packages
RUN pecl install grpc \
    && docker-php-ext-enable grpc
# Setup Composer to Run
RUN mkdir -p /home/$user/.composer \
    && chown -R $user:$user /home/$user

# Setup Nginx
RUN apt update && apt install -y nginx
# RUN mkdir -p /run/nginx
COPY /backend/nginx.conf /etc/nginx/nginx.conf

# Setup rootless Nginx
RUN mkdir -p /var/cache/nginx \
    && mkdir -p /var/log/nginx

RUN chown -R $user:$user /var/cache/nginx \
    && chown -R $user:$user /var/log/nginx \
    && chown -R $user:$user /etc/nginx/conf.d \
    && chown -R $user:$user /var/lib/nginx

RUN chmod -R 777 /var/lib/nginx

RUN touch /var/run/nginx.pid && \
    chown -R www-data:www-data /var/run/nginx.pid \
    && touch /var/log/nginx/error.log \
    && chown www-data:www-data /var/log/nginx/error.log

# Create the backend folders (in advance)
RUN mkdir -p /var/www/yoflo
RUN chown -R $user:$user /var/www/yoflo

# Create Configuration Folders
RUN mkdir -p /etc/yoflo/gcp
RUN chown -R $user:$user /etc/yoflo/gcp

# Cleanup caches and remove unecessary dependencies
RUN apt-get remove --purge --assume-yes git curl \
  && apt-get autoremove --assume-yes \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

USER $user

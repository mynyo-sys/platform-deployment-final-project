FROM php:8.3-fpm

WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    zip \
    unzip \
    libicu-dev \
    libxml2-dev \
    libonig-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extentions
RUN docker-php-ext-install \
    intl \
    xml \
    pdo \
    pdo_mysql \
    mbstring \
    opcache

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin \
    --filename=composer

# Copy project files 
COPY . .

#Install Composer dependencies
RUN composer install \
    --no-interaction \
    --no-dev \
    --optimize-autoloader \
    --no-plugins \
    --no-scripts

#Set proper permissions for Symfony
RUN mkdir -p var/cache var/log var/cache/prod \
    && chmod -R 777 var/ \
    && chown -R www-data:www-data var/

#Copy and set entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/entrypoint.sh"]
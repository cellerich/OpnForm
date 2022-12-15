# Use the official PHP image as the base image
FROM --platform=linux/amd64 php:8.1-fpm

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
        git \
        libicu-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libpq-dev \
        libzip-dev \
        software-properties-common \
        npm \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        intl \
        gd \
        pdo_mysql \
        pdo_pgsql \
        zip \
        exif \
        bcmath

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Node
RUN npm install npm@latest -g && \
    npm install n -g && \
    n 16.0.0

# Copy the application code to the container
COPY . /var/www

# Set the working directory to the application code
WORKDIR /var/www

# Install the application dependencies
# RUN composer update
RUN COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_MIRROR_PATH_REPOS=1 \
    composer install --no-dev

# Build the application assets
RUN php artisan event:cache
RUN npx npm-check-updates -u -t minor
RUN npm install && npm run prod && rm -rf node_modules

# Set the user and group to run the application
# RUN useradd -ms /bin/bash app
# USER app

# Run the application
CMD ["php", "artisan", "migrate", "--force"]


 
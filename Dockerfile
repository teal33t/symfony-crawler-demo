FROM php:7.4-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libicu-dev \
    libzip-dev \
    zip

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql intl zip

# Enable Apache modules
RUN a2enmod rewrite

# Set the document root to the public directory
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Copy the application files to the container
COPY . /var/www/html

# Set the correct file permissions
RUN chown -R www-data:www-data /var/www/html/var

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install application dependencies
RUN composer install --no-scripts --no-autoloader --no-progress --prefer-dist

# Run any necessary build scripts
RUN composer dump-autoload --optimize

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]

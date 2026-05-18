#!/bin/bash
set -e

echo "Fixing permissions..."
chmod -R 777 /var/www/html/var
chown -R www-data:www-data /var/www/html/var

echo "Clearing and warming up Symfony cache..."
php bin/console cache:clear --env=prod --no-debug

echo "Fixing permissions after cache clear..."
chmod -R 777 /var/www/html/var
chown -R www-data:www-data /var/www/html/var

echo "Running database migrations..."
php bin/console doctrine:migrations:migrate --no-interaction --env=prod

echo "Starting PHP-FPM..."
php-fpm -D

echo "Configuring Nginx port..."
envsubst '${PORT}' < /etc/nginx/conf.d/default.conf > /tmp/default.conf
mv /tmp/default.conf /etc/nginx/conf.d/default.conf

echo "Starting Nginx..."
exec nginx -g "daemon off;"
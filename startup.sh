#!/bin/sh

# Copy Configuration Files
cp -s /etc/yoflo/gcp/service.json /var/www/yoflo/config/service.json
cp -s /etc/yoflo/gcp_ps/google-app-credentials.json /var/www/yoflo/config/google-app-credentials.json
cp -s /etc/yoflo/gcp_pubsub/pubsub-service-account.json /var/www/yoflo/config/pubsub.json

# Tell the system to start
php-fpm -D
nginx

php artisan optimize
php artisan serve

# Setup Database
php artisan migrate:status
php artisan migrate

# Don't do fresh migrations, else we keep dropping UAT server
#php artisan migrate:fresh
#php artisan db:seed

# Tell laravel to queue the work
php artisan queue:work

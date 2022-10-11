FROM asia.gcr.io/yoflo-334006/laravel-base/uat:latest

# Set working directory
WORKDIR /var/www/yoflo

# Setup Environment Variable Arguments (if applicable)
ARG user=www-data
ARG uid=33
ARG project=yoflo

# Copy the backend code
COPY --chown=$user:$user . .

# Install Composer Dependencies
RUN composer require fruitcake/laravel-cors
RUN composer install --no-dev

# Final Setup Step
# RUN php artisan clear-compiled
# RUN composer dump-autoload -o
# RUN php artisan optimize

RUN chmod +x /var/www/yoflo/startup.sh

# Copy custom PHP configuration file (required for video file uploads)
COPY ./php.prod.ini /usr/local/etc/php/conf.d/php.ini

EXPOSE 8080
CMD sh /var/www/yoflo/startup.sh
USER $user

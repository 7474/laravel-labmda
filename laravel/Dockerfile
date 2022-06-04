# For lambda
FROM bref/php-81-fpm AS laravel-lambda

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
COPY . /var/task
RUN cd /var/task && composer install --optimize-autoloader --no-dev
RUN rm /usr/local/bin/composer

# XXX Draft SQLite
RUN touch /var/task/database/database.sqlite \
    && chmod 666 /var/task/database/database.sqlite
RUN cp /var/task/.env.example /var/task/.env
RUN cd /var/task && php artisan migrate:fresh --force

CMD ["public/index.php"]

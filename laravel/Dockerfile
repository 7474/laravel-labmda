# For lambda
FROM bref/php-81-fpm AS laravel-lambda

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
COPY . /var/task
RUN cd /var/task && composer install --optimize-autoloader --no-dev
RUN rm /usr/local/bin/composer

CMD ["public/index.php"]

# For lambda
# https://bref.sh/docs/web-apps/docker.html
# https://aws.amazon.com/jp/blogs/news/building-php-lambda-functions-with-docker-container-images/
FROM bref/php-81-fpm AS laravel-lambda

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
COPY . /var/task
RUN cd /var/task && composer install --optimize-autoloader --no-dev
RUN rm /usr/local/bin/composer

ENTRYPOINT [ "/lambda-entrypoint.sh" ]
CMD ["public/index.php"]

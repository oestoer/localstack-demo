FROM php:8-cli-alpine

COPY --from=composer /usr/bin/composer /usr/bin/composer

COPY ./composer.* /app/

WORKDIR /app

RUN composer install --no-interaction --quiet

COPY . /app

ENV AWS_ACCESS_KEY_ID=mock_id
ENV AWS_AWS_SECRET_ACCESS_KEY_ID=mock_secret_key

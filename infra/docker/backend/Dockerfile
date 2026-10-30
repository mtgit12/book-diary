# syntax=docker/dockerfile:1

# 開発用の Laravel(php-fpm)イメージ
FROM php:8.5-fpm-trixie

COPY --from=mlocati/php-extension-installer:2.12.6 /usr/bin/install-php-extensions /usr/local/bin/
COPY --from=composer:2.10 /usr/bin/composer /usr/local/bin/composer

# apt のキャッシュをイメージに残さず、再ビルド時に再利用する(既定ではダウンロードしたパッケージが削除される)
RUN rm -f /etc/apt/apt.conf.d/docker-clean \
    && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

# libfcgi-bin はヘルスチェック(cgi-fcgi で php-fpm の ping を呼ぶ)に使う
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get install -y --no-install-recommends git unzip libfcgi-bin \
    && install-php-extensions bcmath intl pcntl pcov pdo_mysql zip

# 開発用の php.ini を土台にし、個別の設定を上書きする
RUN cp "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
COPY php.ini /usr/local/etc/php/conf.d/zz-app.ini
COPY php-fpm.conf /usr/local/etc/php-fpm.d/zz-app.conf

# ホストのユーザーとファイルの所有者を合わせる
ARG UID=1000
ARG GID=1000
RUN groupmod -o -g "${GID}" www-data \
    && usermod -o -u "${UID}" -g "${GID}" www-data \
    && mkdir -p /var/www/html \
    && chown -R www-data:www-data /var/www

WORKDIR /var/www/html

USER www-data

EXPOSE 9000

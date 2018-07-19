FROM momoirospanner/php-fpm

LABEL maintainer="Hiroaki Tagawa<h.tagawa@momoirospanner.app>"

# Package Install
RUN set -ex \
    && apk update \
    && apk add --no-cache \
        autoconf \
        curl \
        gcc \
        make \
        g++ \
        libintl \
        php7-gd \
        php7-gettext \
        php7-json \
        php7-mbstring \
        php7-fileinfo \
        php7-pdo \
        php7-pdo_pgsql \
        libmcrypt \
        postgresql-dev \
    && apk add --no-cache --virtual .build-php \
        tzdata \
        libpng-dev \
        pcre-dev \
    && cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && docker-php-ext-install \
        gd \
        pdo pdo_pgsql

# Phalcon
ENV PHALCON_VERSION=3.4.0
RUN set -ex \
    && curl -LO https://github.com/phalcon/cphalcon/archive/v${PHALCON_VERSION}.tar.gz \
    && tar xzf v${PHALCON_VERSION}.tar.gz \
    && cd cphalcon-${PHALCON_VERSION}/build \
    && sh install \
    && echo "extension=phalcon.so" > /usr/local/etc/php/conf.d/phalcon.ini \
    && cd ../../ \
    && rm -rf v${PHALCON_VERSION}.tar.gz cphalcon-${PHALCON_VERSION} \
    && apk del .build-php

# Composer
RUN set -ex \
    && cd ~ \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin \
    && mv /usr/local/bin/composer.phar /usr/local/bin/composer \
    && composer require phalcon/devtools \
    && ln -s ~/vendor/phalcon/devtools/phalcon.php /usr/local/bin/phalcon \
    && chmod ugo+x /usr/local/bin/phalcon

FROM php:7.1-apache

MAINTAINER OptimizaClick <devops@optimizaclick.com>


ENV HTTPD_a2enmod='rewrite expires deflate'


RUN apt-get update \
    && apt-get install -y \
        libpng12-dev \
        libjpeg-dev  \
        curl \
        sed \
        git \
        zlib1g-dev \
        libxml2-dev \
        php-soap \
        zlib1g-dev \
        libxml2-dev \
        libpq-dev \
        zlib1g-dev \
        libicu-dev g++ \
    && docker-php-ext-configure \
        gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install \
        zip \
        mysqli \
        opcache \
        gd \
        soap \
        bcmath \
        intl \
        pgsql


# PHP extensions
ENV APCU_VERSION 5.1.7
RUN buildDeps=" \
        libicu-dev \
        zlib1g-dev \
        libsqlite3-dev \
        libpq-dev \
    " \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        $buildDeps \
        libicu52 \
        zlib1g \
        sqlite3 \
        git \
        php5-pgsql \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install \
        intl \
        mbstring \
        pdo_mysql \
        pdo_pgsql \
        pdo \
        pgsql \
        zip \
        pdo_sqlite \
    && apt-get purge -y --auto-remove $buildDeps


RUN echo "file_uploads = On\n" \
         "memory_limit = 512M\n" \
         "upload_max_filesize = 50M\n" \
         "post_max_size = 50M\n" \
         "max_execution_time = 90\n" \
         > /usr/local/etc/php/conf.d/uploads.ini

#TODO: IN DEV the error_reporting must be E_ALL when we finish

RUN { \
    echo 'error_reporting=0'; \
    echo 'disable_functions=error_reporting'; \
} > /usr/local/etc/php/conf.d/error_reporting.ini


# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini



RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

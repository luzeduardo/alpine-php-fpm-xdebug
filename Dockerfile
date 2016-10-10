FROM alpine:3.3
MAINTAINER Eduardo Luz <luz.eduardo@gmail.com>

ENV TIMEZONE            America/Sao_Paulo
ENV PHP_MEMORY_LIMIT    512M
ENV MAX_UPLOAD          100M
ENV PHP_MAX_FILE_UPLOAD 200
ENV PHP_MAX_POST        100M
ENV XDEBUG_VERSION 2.3.3

RUN apk update && apk add --no-cache --virtual .build-deps autoconf gcc make \
    g++ zlib-dev file g++ libc-dev make pkgconf \
    tar curl php-pear tzdata php-dev php-phar libmemcached-dev \
    && apk add php php-cli php-curl php-gd git php-json libmemcached \
    && cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo "${TIMEZONE}" > /etc/timezone \

#PHP Libs
&& apk add \
    php-iconv \
    php-mcrypt \
    php-soap \
    php-openssl \
    php-gmp \
    php-json \
    php-pdo \
    php-mysql \
    php-xcache \
    php-pdo_mysql \
    php-gettext \
    php-xmlrpc \
    php-bz2 \
    php-memcache \
    php-ldap \
    php-mysqli \
    php-ctype \
    php-fpm \
    php-dom \
    php-phar \


# Set environments
&& curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/bin/composer \

&& sed -i "s|;*daemonize\s*=\s*yes|daemonize = no|g" /etc/php/php-fpm.conf && \
    sed -i "s|;*listen\s*=\s*127.0.0.1:9000|listen = 9000|g" /etc/php/php-fpm.conf && \
    sed -i "s|;*listen\s*=\s*/||g" /etc/php/php-fpm.conf && \
    sed -i "s|;*date.timezone =.*|date.timezone = ${TIMEZONE}|i" /etc/php/php.ini && \
    sed -i "s|;*memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" /etc/php/php.ini && \
    sed -i "s|;*upload_max_filesize =.*|upload_max_filesize = ${MAX_UPLOAD}|i" /etc/php/php.ini && \
    sed -i "s|;*max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|i" /etc/php/php.ini && \
    sed -i "s|;*post_max_size =.*|post_max_size = ${PHP_MAX_POST}|i" /etc/php/php.ini && \
    sed -i "s|;*cgi.fix_pathinfo=.*|cgi.fix_pathinfo= 0|i" /etc/php/php.ini \

#Xdebug
&& cd /tmp && wget http://xdebug.org/files/xdebug-$XDEBUG_VERSION.tgz \
    && tar -zxvf xdebug-$XDEBUG_VERSION.tgz \
    && cd xdebug-$XDEBUG_VERSION && phpize \
    && ./configure --enable-xdebug && make && make install \
    && echo "zend_extension=$(find /usr/lib/php/modules/ -name xdebug.so)" > /etc/php/php.ini \
    && echo "xdebug.remote_enable=on" >> /etc/php/php.ini \
    && echo "xdebug.remote_handler=dbgp" >> /etc/php/php.ini \
    && echo "xdebug.remote_connect_back=1" >> /etc/php/php.ini \
    && echo "xdebug.remote_autostart=on" >> /etc/php/php.ini \
    && echo "xdebug.remote_port=9004" >> /etc/php/php.ini \
    && rm -rf tmp/* \

# Bug pecl Alpine && Install php-memcached by PECL
&& sed -i "s/\ \-n\ / /" $(which pecl) && \
    cd /usr/local/ && pecl download memcached && tar -xf $(ls -1 memcached*); \
    cd "$(ls -d ./memcache*|grep -v "\.tar")" \
    && phpize \
    && ./configure --disable-memcached-sasl --with-php-config=/usr/bin/php-config \
    --includedir=/usr/include --with-libdir=/usr/include --enable-memcached \
    && make && make install && echo -e "extension=\"memcached.so\"\n" > /etc/php/conf.d/memcached.ini \
    && rm -rf "$(ls -d /usr/local/memcache*|grep -v "\.tar")" \
    && rm "$(ls /usr/local/memcache*.tar)" \
    && rm -rf /var/cache/apk/* \

#Cleanup
   && rm -rf /var/cache/apk/* \
   && apk del .build-deps

# Set Workdir
WORKDIR /var/www/html

# Expose ports
EXPOSE 9000
EXPOSE 9004
# Entry point
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

FROM luzeduardo/alpine-php-fpm
MAINTAINER Eduardo Luz <luz.eduardo@gmail.com>

ENV TIMEZONE            America/Sao_Paulo
ENV PHP_MEMORY_LIMIT    512M
ENV MAX_UPLOAD          100M
ENV PHP_MAX_FILE_UPLOAD 200
ENV PHP_MAX_POST        100M

ENV XDEBUG_VERSION 2.3.3
RUN wget http://xdebug.org/files/xdebug-$XDEBUG_VERSION.tgz \
    && tar -zxvf xdebug-$XDEBUG_VERSION.tgz \
    && cd xdebug-$XDEBUG_VERSION && phpize \
    && ./configure --enable-xdebug && make && make install \
    && echo "zend_extension=$(find /usr/lib/php/modules/ -name xdebug.so)" > /etc/php/php.ini \
    && echo "xdebug.remote_enable=on" >> /etc/php/php.ini \
    && echo "xdebug.remote_handler=dbgp" >> /etc/php/php.ini \
    && echo "xdebug.remote_connect_back=1" >> /etc/php/php.ini \
    && echo "xdebug.remote_autostart=on" >> /etc/php/php.ini \
    && echo "xdebug.remote_port=9004" >> /etc/php/php.ini \
    && echo "date.timezone = \"America/Sao_Paulo\";" >> /etc/php/php.ini \
    && rm -rf /var/cache/apk/* \
    && rm xdebug-$XDEBUG_VERSION.tgz && rm -rf xdebug-$XDEBUG_VERSION

WORKDIR /var/www/html

# Expose ports
EXPOSE 9000
EXPOSE 9004

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

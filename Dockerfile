# NOTE: only add file if building for arm
FROM php:8.2-alpine AS build

ARG MAILU_UID=1000
ARG MAILU_GID=1000

RUN addgroup -Sg ${MAILU_GID} mailu \
  && adduser -Sg ${MAILU_UID} -G mailu -h /app -g "mailu app" -s /bin/sh mailu
  
#Shared layer between rainloop and roundcube
RUN apk add --update --no-cache \
  python3 curl git nginx

RUN python3 -m ensurepip

# Shared layer between nginx, dovecot, postfix, postgresql, rspamd, unbound, rainloop, roundcube
RUN pip3 install socrate

ENV ROUNDCUBE_URL https://github.com/roundcube/roundcubemail/releases/download/1.6.2/roundcubemail-1.6.2-complete.tar.gz

ENV CARDDAV_URL https://github.com/blind-coder/rcmcarddav/releases/download/v5.0.1/carddav-v5.0.1.tar.gz

ENV MFA_URL https://github.com/alexandregz/twofactor_gauthenticator.git 

RUN  apk add --update --no-cache \
    libzip-dev libpq-dev \
    php81 php81-fpm php81-mbstring php81-zip php81-xml php81-simplexml php81-pecl-apcu \
    php81-dom php81-curl php81-exif gd php81-gd php81-iconv php81-intl php81-openssl php81-ctype \
    php81-pdo_sqlite php81-pdo_mysql php81-pdo_pgsql php81-pdo php81-sodium libsodium php81-tidy php81-pecl-uuid \
    php81-pspell php81-pecl-imagick php81-opcache php81-session php81-sockets php81-fileinfo php81-xmlreader php81-xmlwriter \
    aspell-uk aspell-ru aspell-fr aspell-de aspell-en \
 && docker-php-ext-install zip pdo_mysql pdo_pgsql \
 && echo date.timezone=UTC > /usr/local/etc/php/conf.d/timezone.ini \
 && rm -rf /var/www/html/ \
 && cd /var/www \
 && curl -L -O ${ROUNDCUBE_URL} \
 && curl -L -O ${CARDDAV_URL} \
 && git clone  ${MFA_URL} \
 && ls *.tar.gz |xargs -n1 tar -xzf \
 && rm -f *.tar.gz \
 && mv roundcubemail-* html \
 && mv carddav html/plugins/ \
 && mv twofactor_gauthenticator html/plugins/ \
 && cd html \
 && rm -rf CHANGELOG INSTALL LICENSE README.md UPGRADING composer.json-dist installer \
 && rm -rf plugins/{autologon,example_addressbook,http_authentication,krb_authentication,new_user_identity,password,redundant_attachments,squirrelmail_usercopy,userinfo,virtuser_file,virtuser_query} \
 && rm /etc/nginx/http.d/default.conf \
 && rm /etc/php81/php-fpm.d/www.conf 

COPY php.ini /php.ini
COPY config.inc.php /var/www/html/config/
COPY php-webmail.conf /etc/php81/php-fpm.d/
COPY nginx-webmail.conf /conf/
COPY start.py /start.py
COPY snuffleupagus.rules /etc/snuffleupagus.rules.tpl

EXPOSE 80/tcp
VOLUME ["/data"]

CMD ["python3", "/start.py"]

HEALTHCHECK CMD curl -f -L http://localhost/ || exit 1
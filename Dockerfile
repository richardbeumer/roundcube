# NOTE: only add file if building for arm
FROM php:8.3-alpine AS build

ARG MAILU_UID=1000
ARG MAILU_GID=1000

ENV \
  VIRTUAL_ENV=/app/venv \
  PATH="/app/venv/bin:${PATH}" \
  ROUNDCUBE_URL=https://github.com/roundcube/roundcubemail/releases/download/1.6.7/roundcubemail-1.6.7-complete.tar.gz \
  CARDDAV_URL=https://github.com/blind-coder/rcmcarddav/releases/download/v5.1.0/carddav-v5.1.0.tar.gz \
  MFA_URL=https://github.com/alexandregz/twofactor_gauthenticator.git 

WORKDIR /app  

COPY libs/ libs/
COPY requirements.txt ./

RUN addgroup -Sg ${MAILU_GID} mailu \
  && adduser -Sg ${MAILU_UID} -G mailu -h /app -g "mailu app" -s /bin/sh mailu
  
#Shared layer between rainloop and roundcube
RUN apk add --update --no-cache \
  python3 curl git nginx

RUN set -euxo pipefail \
  ; apk add --no-cache py3-pip \
  ; python3 -m venv ${VIRTUAL_ENV} \
  ; ${VIRTUAL_ENV}/bin/pip install --no-cache-dir -r requirements.txt \
  ; apk del -r py3-pip \
  ; rm -f /tmp/*.pem

RUN  apk add --update --no-cache \
    libzip-dev libpq-dev \
    php83 php83-fpm php83-mbstring php83-zip php83-xml php83-simplexml php83-pecl-apcu \
    php83-dom php83-curl php83-exif gd php83-gd php83-iconv php83-intl php83-openssl php83-ctype \
    php83-pdo_sqlite php83-pdo_mysql php83-pdo_pgsql php83-pdo php83-sodium libsodium php83-tidy php83-pecl-uuid \
    php83-pspell php83-pecl-imagick php83-opcache php83-session php83-sockets php83-fileinfo php83-xmlreader php83-xmlwriter \
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
 && mv roundcubemail-* roundcube \
 && mv carddav roundcube/plugins/ \
 && mv twofactor_gauthenticator roundcube/plugins/ \
 && cd roundcube \
 && rm -rf CHANGELOG INSTALL LICENSE README.md UPGRADING composer.json-dist installer \
 && rm -rf plugins/{autologon,example_addressbook,http_authentication,krb_authentication,new_user_identity,password,redundant_attachments,squirrelmail_usercopy,userinfo,virtuser_file,virtuser_query} \
 && rm /etc/nginx/http.d/default.conf \
 && rm /etc/php83/php-fpm.d/www.conf 

COPY php.ini /defaults/
COPY config.inc.php /conf/
COPY php-webmail.conf /etc/php83/php-fpm.d/
COPY nginx-webmail.conf /conf/
COPY start.py /start.py
COPY snuffleupagus.rules /etc/snuffleupagus.rules.tpl

EXPOSE 80/tcp
VOLUME ["/data"]

CMD ["python3", "/start.py"]

HEALTHCHECK CMD curl -f -L http://localhost/ || exit 1
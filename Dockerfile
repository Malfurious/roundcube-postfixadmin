FROM malfurious/nginx-php

LABEL description "Roundcube-Postfix is a simple, modern & fast webmail client combined with an administrative Postfixadmin webportal to manage postfix accounts." \
      maintainer="Malfurious <jmay9990@gmail.com>"
	  
ARG ROUND_VERSION=1.3.1
ARG POST_VERSION=3.1
ENV UID=991 GID=991 UPLOAD_MAX_SIZE=25M MEMORY_LIMIT=128M
ENV PLUGINS=" 'password','enigma'"
RUN echo "@community https://nl.alpinelinux.org/alpine/v3.6/community" >> /etc/apk/repositories \
 && apk -U upgrade
RUN apk add gnupg openssl dovecot tini@community
RUN apk add -t build-dependencies \
    wget \
    git \
    curl \
	ca-certificates \
	coreutils \
	gcc \
	linux-headers \
	make \
	musl-dev \
 && cd /tmp \
 && wget -q https://github.com/roundcube/roundcubemail/releases/download/${ROUND_VERSION}/roundcubemail-${ROUND_VERSION}-complete.tar.gz \
 && wget -q https://downloads.sourceforge.net/project/postfixadmin/postfixadmin/postfixadmin-${POST_VERSION}/postfixadmin-${POST_VERSION}.tar.gz
RUN mkdir /roundcube && tar -xzf /tmp/roundcubemail-${ROUND_VERSION}-complete.tar.gz --strip 1 -C /roundcube \
 && mv /roundcube/config/config.inc.php.sample /roundcube/config/config.inc.php && mv /roundcube/composer.json-dist /roundcube/composer.json
RUN mkdir /postfixadmin && tar xzf /tmp/postfixadmin-${POST_VERSION}.tar.gz -C /postfixadmin && mv /postfixadmin/postfixadmin-${POST_VERSION}/* /postfixadmin
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/roundcube/ --filename=composer.phar
RUN cd /roundcube && php composer.phar install --no-dev \
 && find /roundcube -type d -exec chmod 755 {} \; \
 && find /roundcube -type f -exec chmod 644 {} \; \
 && apk del build-dependencies \
 && rm -rf /tmp/* /var/cache/apk/* /root/.gnupg /postfixadmin/postfixadmin-${POST_VERSION}*

RUN mkdir /enigma && mv /roundcube/plugins/password/config.inc.php.dist /roundcube/plugins/password/config.inc.php \
 && mv /roundcube/plugins/enigma/config.inc.php.dist /roundcube/plugins/enigma/config.inc.php
RUN sed -i "/'zipdownload',/a ${PLUGINS}" /roundcube/config/config.inc.php
COPY rootfs /
RUN chmod +x /usr/local/bin/* /etc/s6.d/*/* /etc/s6.d/.s6-svscan/*
EXPOSE 8888 8080
VOLUME /enigma
CMD ["tini", "--", "run.sh"]

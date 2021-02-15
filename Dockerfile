FROM php:7-apache
MAINTAINER Toai Vo <toaivo@stanford.edu>

ARG USERUID

RUN apt-get -qq update && \
    apt-get -qq -y --no-install-recommends install \
       libapache2-mod-shib2 && \
    mkdir /etc/apache2/certs && \
    a2enmod ssl && \
    a2ensite default-ssl

COPY files/apache/ports.conf /etc/apache2/ports.conf

COPY files/apache/default-ssl.conf files/apache/000-default.conf \
     /etc/apache2/sites-enabled/

COPY files/shibb/sp-cert.pem \
     files/shibb/sp-key.pem \
     files/shibb/shibboleth2.xml \
     files/shibb/attribute-map.xml \
     files/shibb/protocols.xml \
     /etc/shibboleth/

COPY files/php/php.ini /usr/local/etc/php

COPY files/apache/apache2-foreground \
     /usr/local/bin/

RUN cd /etc/shibboleth && \
    chown _shibd sp-*.pem && \
    chmod go= sp-key.pem && \
    usermod -u ${USERUID} www-data && \
    apt-get clean 

EXPOSE 80 443

WORKDIR /var/www/html

ENTRYPOINT ["apache2-foreground"]

FROM centos:centos7 as base

LABEL name="lumen"
LABEL maintainer="Thabet Amer <thabet.amer@gmail.com>"
LABEL version="3.0"
LABEL summary="Lumen server with Apache, php, supervisor and cron"

# env
# note: PHP version as in remi repo
ARG PHP_VERSION="73"
ARG ROOT_PASSWORD="Docker!"

USER root
RUN echo "root:${ROOT_PASSWORD}" | chpasswd

# install PHP ${PHP_VERSION} and dev tools
RUN true \
    && yum -y install --setopt=tsflags=nodocs \
        yum-utils \ 
        https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
        http://rpms.remirepo.net/enterprise/remi-release-7.rpm \
        curl \
        httpd \
        zip \
        unzip \
        crontabs \
    && yum-config-manager --enable remi-php${PHP_VERSION} \
    && yum -y install --setopt=tsflags=nodocs \
        php php-common php-mysql php-mcrypt php-gd php-curl php-json php-zip php-xml php-fileinfo php-bcmath \
        libpng12-devel \
        libpng-devel \
        pngquant \
        supervisor \
        composer \
    && yum -y clean all \
    && rm -rf /var/cache/yum


FROM base as build

# env
ARG TIMEZONE="UTC"
RUN ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime

USER root

# custom configs for php.ini, add yours here.
RUN sed -i '\
            s/;\?short_open_tag =.*/short_open_tag = On/; \
            s/;\?expose_php =.*/expose_php = Off/; \
            s/;\?post_max_size =.*/post_max_size = 101M/; \
            s/;\?upload_max_filesize =.*/upload_max_filesize = 101M/; \
            s/;\?max_execution_time =.*/max_execution_time = 120/; \
            s/;\?memory_limit =.*/memory_limit = 512M/; \
            s#;\?date.timezone =.*#date.timezone = '${TIMEZONE}'# \
            ' /etc/php.ini \
    && cp /etc/php.ini . \
    && ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime

COPY . /var/www/html

WORKDIR /var/www/html/

COPY ./devops/apache.conf /etc/httpd/conf.d/host.conf
COPY ./devops/crontab.conf /etc/crontab
COPY ./devops/supervisord.conf /etc/

RUN ./devops/build.sh

EXPOSE 80
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

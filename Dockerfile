FROM centos:centos7 as base

LABEL name="vue"
LABEL maintainer="Thabet Amer <thabet.amer@gmail.com>"
LABEL version="3.0"
LABEL summary="Vue web server with with node and npm"

# env
ARG NODE_VERSION="12"
ARG ROOT_PASSWORD="Docker!"

USER root
RUN echo "root:${ROOT_PASSWORD}" | chpasswd

# install necessary tools
RUN true \
    && yum -y install --setopt=tsflags=nodocs \
	curl \
	httpd \
	libpng12-devel \
	libpng-devel \
	pngquant \
    && curl -sL https://rpm.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && yum -y install --setopt=tsflags=nodocs nodejs \
    && npm install -g cross-env \
    && yum -y clean all \
    && rm -rf /var/cache/yum


FROM base as build

# env
ARG TIMEZONE="UTC"
RUN ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime

USER root

COPY . /var/www/html

WORKDIR /var/www/html/

COPY ./devops/apache.conf /etc/httpd/conf.d/host.conf

RUN ./devops/build.sh

EXPOSE 80
CMD ["/usr/sbin/apachectl","-DFOREGROUND"]

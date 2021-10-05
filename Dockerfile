FROM ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractive

# install packages and dependencies
RUN apt-get update \
  && dpkg-divert --local --rename --add /sbin/initctl \
  && ln -sf /bin/true /sbin/initctl \
  && echo "postfix postfix/mailname string drupal-mail" | debconf-set-selections \
  && echo "postfix postfix/main_mailer_type string 'Local only'" | debconf-set-selections \
  && apt-get -y install curl wget supervisor openssh-server locales \
       apache2 pwgen vim-tiny mc iproute2 python-setuptools git \
       unison netcat net-tools memcached nano libapache2-mod-php php php-cli php-common \
       php-gd php-json php-mbstring php-xdebug php-mysql php-opcache php-curl \
       php-readline php-xml php-memcached php-oauth php-bcmath \
       postfix mailutils \
  && apt-get clean \
  && apt-get autoclean \
  && apt-get -y autoremove \
  && rm -rf /var/lib/apt/lists/*

# emails handling
RUN echo site: root >> /etc/aliases \
  && echo admin: root >> /etc/aliases \
  && newaliases

# ssh
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
  && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config

# install Composer and drupal console
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  && curl https://drupalconsole.com/installer -L -o /usr/local/bin/drupal \
  && chmod +x /usr/local/bin/drupal

RUN rm /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-enabled/*

# copy configs
COPY ./devops/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./devops/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY ./devops/xdebug.ini /etc/php/*/mods-available/xdebug.ini
COPY ./devops/start.sh /start.sh

# finale
RUN locale-gen en_US.UTF-8 \
  && a2ensite 000-default \
  && a2enmod rewrite vhost_alias \
  && mkdir -p /var/lock/apache2 /var/run/apache2 /var/run/sshd /var/log/supervisor \
  && chmod u+x /start.sh

WORKDIR /var/www/html

EXPOSE 22 80
CMD ["/bin/bash", "/start.sh"]

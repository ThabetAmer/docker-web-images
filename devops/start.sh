#!/bin/bash

export ROOT_PASSWORD="goOBI@2021"
export BASEHTML="/var/www/html"
export DOCROOT="/var/www/html/web"
export DRUSH="/.composer/vendor/drush/drush/drush"
export LOCAL_IP=$(hostname -I| awk '{print $1}')
export HOSTIP=$(/sbin/ip route | awk '/default/ { print $3 }')
echo "${HOSTIP} dockerhost" >> /etc/hosts
echo "Started Container: $(date)"

# Start supervisord
supervisord -c /etc/supervisor/conf.d/supervisord.conf -l /tmp/supervisord.log

# Change root password
echo "root:${ROOT_PASSWORD}" | chpasswd

# Clear caches and reset files perms
chown -R www-data:www-data ${DOCROOT}
chmod -R ug+w ${DOCROOT}
find -type d -exec chmod +xr {} \;
#(sleep 3; drush --root=${DOCROOT}/ cache-rebuild 2>/dev/null) &

composer install

echo
echo "---------------------- USERS CREDENTIALS ($(date +%T)) -------------------------------"
echo
echo "    DRUPAL:  http://${LOCAL_IP}              with user/pass: admin/admin"
echo
echo "    SSH   :  ssh root@${LOCAL_IP}            with user/pass: root/${ROOT_PASSWORD}"
echo
echo "------------------------------ STARTING SERVICES ---------------------------------------"

php --version && composer --version && drupal --version

tail -f /tmp/supervisord.log


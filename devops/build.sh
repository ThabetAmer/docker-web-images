#!/bin/bash

#
# Commands to run while building the container
#

[ -d storage/logs ] || mkdir -p storage/logs
[ -d public ] || mkdir -p public

[ -f composer.json ] || exit 0

composer install --no-interaction --no-progress  --prefer-dist --optimize-autoloader --ignore-platform-reqs --no-suggest --no-dev

# npm
npm install
npm run prod

#php artisan optimize

#php artisan key:generate

#php artisan migrate

# clearing cache
#php artisan cache:clear
#php artisan config:clear

# caching new changes
#php artisan config:cache
#php artisan route:cache

#php artisan storage:link

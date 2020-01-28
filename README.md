# Docker Images for web services

Currently supports Laravel, Lumen and Vue.js

## Structure

* Centos as base Image.
* Httpd or Nginx - per tag/branch.
* PHP - different versions per tag.
* PHP libs plus auxiliary tools: curl, zip, crontab and composer.
* Supervisor to hold services - listed below.

## Services

* Web server.
* Crontab for scheduled tasks.
* Artisan queue manager.
* Artisan consumer.

## Instructions

* Edit `devops/build.sh` to add your custom instruction on building your app.
* Edit `devops/init.sh` to select steps necessary when the container boots, comment out unwanted supervisor processes.
* You may add cronjobs in `devops/crontab.conf`
* You may tune _php_ custom configurations in `Dockerfile`, and/or timezone for container instance.
* You may add port 443 to `Dockerfile` if you don't have a reverse proxy/load balancer for handling SSL connections.
* You may need to edit `devops/supervisor.conf`, for example to select queue name for _consumer_ process.
* Add your source code to directory.
* You may add unwanted files/folder to `.dockerignore`
* Run Docker build.

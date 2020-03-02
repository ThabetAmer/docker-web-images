#!/bin/bash

#
# Commands to run after booting up the container
#

# 1001 is the ops group number
chown apache:1001 -R storage uploads
chmod ug+rwx -R storage uploads
umask 0002

# start other supervisor jobs
## you may need to edit consumer name in supervisor.conf
supervisorctl start crontab

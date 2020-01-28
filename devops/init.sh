#!/bin/bash

#
# Commands to run after booting up the container
#

# 1001 is the ops group number
chown apache:1001 -R storage public
chmod ug+rwx -R storage public
umask 0002

# start other supervisor jobs
## you may need to edit consumer name in supervisor.conf
supervisorctl start queue:*
supervisorctl start crontab
supervisorctl start consumer

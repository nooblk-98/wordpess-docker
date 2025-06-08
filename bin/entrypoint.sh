#!/bin/bash
set -e

# database availability check
/usr/local/bin/db-helth-check.sh || exit 1

# wordpress init 
/usr/local/bin/init.sh

# Fix wordperss permissions
chown -R  www-data:www-data /var/www/html

# Start supervisor services (ginx, php-fpm)
exec supervisord -c /etc/supervisord.conf
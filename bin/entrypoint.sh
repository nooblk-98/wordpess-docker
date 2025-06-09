#!/bin/bash
set -e

# database availability check
/usr/local/bin/db-helth-check.sh || exit 1

# wordpress init 
/usr/local/bin/init.sh

# Set PHP upload and memory limits
echo "upload_max_filesize=${PHP_UPLOAD_MAX_FILESIZE:-64M}" > /usr/local/etc/php/conf.d/uploads.ini
echo "post_max_size=${PHP_POST_MAX_SIZE:-64M}" >> /usr/local/etc/php/conf.d/uploads.ini
echo "memory_limit=${PHP_MEMORY_LIMIT:-512M}" > /usr/local/etc/php/conf.d/memory-limit.ini

# Fix wordperss permissions
chown -R  www-data:www-data /var/www/html

# Start supervisor services (ginx, php-fpm)
exec supervisord -c /etc/supervisord.conf
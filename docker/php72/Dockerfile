FROM ghcr.io/nooblk-98/php-docker-nginx:php72

# Set working directory
WORKDIR /var/www/html

# Install unzip and WP-CLI
RUN apk add --no-cache dos2unix unzip less nano netcat-openbsd \
  && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
  && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp


# Increase PHP memory limit to avoid wp-cli crash
RUN echo "memory_limit = 512M" > /usr/local/etc/php/conf.d/memory-limit.ini 

# Copy and fix entrypoint script
COPY bin/entrypoint.sh /entrypoint.sh
COPY config/wp-config.php /var/www/html/wp-config.php
COPY scripts/init.sh /usr/local/bin/init.sh
COPY scripts/db-helth-check.sh /usr/local/bin/db-helth-check.sh

# setup  entrypoint
RUN chmod +x /usr/local/bin/init.sh && \
    chmod +x /usr/local/bin/db-helth-check.sh && \
    dos2unix /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
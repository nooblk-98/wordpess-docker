#!/bin/bash
set -e

INIT_FLAG="/var/www/html/.wp-init-done"

# Skip initialization if already done
if [ -f "$INIT_FLAG" ]; then
  echo "✅ WordPress already initialized. Skipping setup."
  exit 0
fi

# Download WordPress core if missing
if [ ! -f /var/www/html/wp-settings.php ]; then
  echo "⬇️ Downloading WordPress core..."
  wp core download --allow-root --path=/var/www/html
else
  echo "ℹ️ WordPress core already exists. Skipping download."
fi

# Copy wp-config.php to the correct location
echo "📋 Copying wp-config.php to WordPress directory..."
wget https://raw.githubusercontent.com/nooblk-98/wordpess-docker/refs/heads/main/config/wp-config.php -O /var/www/html/wp-config.php

# Install WordPress
echo "⚙️ Installing WordPress..."
wp core install \
  --url="http://localhost:8080" \
  --title="${WP_SITE_TITLE}" \
  --admin_user="${WP_ADMIN_USER}" \
  --admin_password="${WP_ADMIN_PASSWORD}" \
  --admin_email="${WP_ADMIN_EMAIL}" \
  --skip-email \
  --allow-root

# Install plugins
if [ -n "$WP_PLUGINS" ]; then
  echo "📦 Installing plugins: $WP_PLUGINS"
  wp plugin install $WP_PLUGINS --activate --allow-root || echo "⚠️ Failed to install some plugins"
else
  echo "ℹ️ No plugins to install"
fi

# Update WordPress core
wp core update --allow-root

# Remove default plugins
wp plugin delete akismet hello --allow-root

# ✅ Create the init flag
touch "$INIT_FLAG"
echo "✅ Initialization complete!"

#!/bin/sh

# Use WordPress-specific env vars
DB_HOST=${WORDPRESS_DB_HOST:-mariadb}
DB_PORT=3306

echo "⏳ Waiting for MySQL to be reachable ..."

while ! nc -z "$DB_HOST" "$DB_PORT"; do
  echo "❌ MySQL not ready... retrying in 2s"
  sleep 2
done

echo "✅ MySQL is ready!"

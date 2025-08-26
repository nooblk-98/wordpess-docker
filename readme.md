##  WordPress Docker Deployment Guide

This stack enables deploying a **production-ready WordPress site** using Docker. It includes:

* ✅ WordPress with WP-CLI
* ✅ Plugin auto-installation
* ✅ Database initialization check
* ✅ Optional support for external databases
* ✅ Base PHP image : `ghcr.io/nooblk-98/php-docker-nginx:php82`

---

## 🖥️ Platform Support

✅ **Supports both ARM64 and AMD64 architectures**
This image is built with multi-architecture support and runs seamlessly on:

* Apple Silicon (M1/M2)
* AWS Graviton
* Intel/AMD-based servers and desktops

---
## 🛠️ Setup Instructions

### Create folder  and copy docker compose file and `env_example` as `.env` 
    sample docker-compose.yml

```bash
services:
  wordpress:
    image: lahiru98s/wordpess-docker:php82
    container_name: ${PROJECT_NAME}
    hostname: localhost
    environment:
      WP_SITE_TITLE: ${WP_SITE_TITLE}
      WP_ADMIN_USER: ${WP_ADMIN_USER}
      WP_ADMIN_PASSWORD: ${WP_ADMIN_PASSWORD}
      WP_ADMIN_EMAIL: ${WP_ADMIN_EMAIL}
      WORDPRESS_DB_HOST: ${MYSQL_HOST}
      WORDPRESS_DB_NAME: ${MYSQL_DATABASE}
      WORDPRESS_DB_USER: ${MYSQL_USER}
      WORDPRESS_DB_PASSWORD: ${MYSQL_PASSWORD}
      WP_PLUGINS: ${WP_PLUGINS}
      PHP_UPLOAD_MAX_FILESIZE: ${UPLOAD_MAX}
      PHP_POST_MAX_SIZE: ${POST_MAX}
      PHP_MEMORY_LIMIT: ${MEMORY_LIMIT}
      WORDPRESS_DEBUG: false
    volumes:
      - web_data:/var/www/html
    ports:
      - "8080:80"
    depends_on:
      - mariadb

  mariadb:
    image: mariadb:10
    container_name: ${PROJECT_NAME}-db
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    volumes:
      - db_data:/var/lib/mysql
    ports:
      - "3306:3306"

volumes:
  db_data:
  web_data:

```

### Copy and configure environment variables

```bash
cp .env_example .env
# Then edit .env to set your DB, WP Admin, and plugin settings
```
```bash
# Wordperss secrets 
PROJECT_NAME=wordperss
MYSQL_DATABASE=wordpress_database
MYSQL_USER=wordpress_user
MYSQL_PASSWORD=YW08dsm0XP2cek6f
MYSQL_ROOT_PASSWORD=lb9tjjGGHTIvZZr6
MYSQL_HOST=mariadb

# admin secrets 
WP_SITE_TITLE=wordperss
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=secureAdmin123
WP_ADMIN_EMAIL=admin@example.com

# pre install plugin list 
WP_PLUGINS="advanced-custom-fields temporary-login-without-password all-in-one-wp-migration"


# PHP Limits
UPLOAD_MAX=256M
POST_MAX=256M
MEMORY_LIMIT=512M

````
---

## 🔄 Deploy with Internal MariaDB

### 3. Start the containers

```bash
docker compose up --build -d
```

This will:

* Build the custom WordPress image
* Launch MariaDB container
* Auto-install WordPress and plugins
* Skip setup if `.wp-init-done` exists

### 4. Access your site

Go to: [http://localhost:8080](http://localhost:8080)

---

## 🌐 Deploy with External Database

To connect to an external MySQL or MariaDB host:

### 1. Set database env in `.env`

```env
MYSQL_HOST=db.myhost.com
MYSQL_DATABASE=external_db
MYSQL_USER=wp_user
MYSQL_PASSWORD=securepass
```

### 2. Comment out the `mariadb:` service in `docker-compose.yml`

```yaml
# mariadb:
#   image: mariadb:10
#   ...
```

### 3. Rebuild and restart only the WordPress container

```bash
docker compose up --build -d wordpress
```

---

## ⚙️ Features

* 📦 Auto installs WordPress core if not present
* 🔐 Secure admin credentials via `.env`
* 🔁 Idempotent: skips reinstallation on restart
* 🔌 Auto-installs plugins via WP-CLI from `.env` list
* 🔄 Graceful MySQL wait via `nc` (no segfaults)
* 🗃️ Works with both internal and external databases

---

## ✅ Advantages

| Feature                   | Benefit                                    |
| ------------------------- | ------------------------------------------ |
| Dockerized Stack          | Easy to deploy, manage, and scale          |
| Plugin Auto-Installer     | Declarative setup via `.env`               |
| Persistent Volume Support | WordPress content and DB survive restarts  |
| Custom Entry Point        | Handles DB wait and re-init skip reliably  |
| External DB Compatible    | Great for shared or cloud-hosted databases |
| Secure Configuration      | Secrets stored in `.env`, not hardcoded    |
| Flexible Port Mapping     | Customizable with Docker Compose           |

---

## 🧪 Environment Variables Reference

| Variable            | Purpose                         |
| ------------------- | ------------------------------- |
| `PROJECT_NAME`      | Docker container name           |
| `MYSQL_HOST`        | DB hostname (internal/external) |
| `MYSQL_DATABASE`    | DB name                         |
| `MYSQL_USER`        | DB user                         |
| `MYSQL_PASSWORD`    | DB password                     |
| `WP_SITE_TITLE`     | WordPress site title            |
| `WP_ADMIN_USER`     | Admin username                  |
| `WP_ADMIN_PASSWORD` | Admin password                  |
| `WP_ADMIN_EMAIL`    | Admin email                     |
| `WP_PLUGINS`        | Space-separated plugin slugs    |

---

## 📦 Plugin Management

To add plugins, just edit `.env`:

```env
WP_PLUGINS="plugin-one plugin-two"
```

They will be installed and activated during the first container startup.

---

## Contributing

Contributions are always welcome!


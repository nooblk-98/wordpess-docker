<div align="center">

# WordPress Docker Stack

[![Build Status](https://img.shields.io/github/actions/workflow/status/nooblk-98/wordpess-docker/build-all-php.yml?branch=main&style=flat-square&label=BUILD)](https://github.com/nooblk-98/wordpess-docker/actions)
[![Docker Pulls](https://img.shields.io/docker/pulls/nooblk98/wordpess-docker?style=flat-square&label=DOCKER%20PULLS)](https://hub.docker.com/r/lahiru98s/wordpess-docker)
[![GitHub repo size](https://img.shields.io/github/repo-size/nooblk-98/wordpess-docker?style=flat-square&label=REPO%20SIZE)](https://github.com/nooblk-98/wordpess-docker)
[![License](https://img.shields.io/github/license/nooblk-98/wordpess-docker?style=flat-square&label=LICENSE)](https://github.com/nooblk-98/wordpess-docker/blob/main/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/nooblk-98/wordpess-docker?style=flat-square&label=STARS)](https://github.com/nooblk-98/wordpess-docker/stargazers)

**Production-ready WordPress + Nginx Docker containers for modern web applications**

*Supporting WordPress, WP-CLI automation, multi-PHP versions, and any WordPress application*

[Quick Start](#quick-start) • [Available Images](#available-images) • [Usage](#deployment-options) • [Performance](#maintenance-operations)

</div>

## Overview

This project provides containerized WordPress with optimized configurations for production environments. It includes automated WordPress installation, plugin management, and supports both bundled and external database configurations.

### Key Features

- **Multi-PHP Support**: Available for PHP 5.6, 7.2, 7.4, 8.1, 8.2, and 8.3
- **Automated Setup**: WordPress auto-installation with configurable admin accounts
- **Plugin Management**: Automatic plugin installation and activation via environment variables
- **WP-CLI Integration**: Built-in WordPress command-line interface
- **Database Flexibility**: Supports both bundled MariaDB and external database connections
- **Production Ready**: Optimized Nginx and PHP-FPM configuration
- **Multi-Architecture**: ARM64 and AMD64 support (Apple Silicon, AWS Graviton, Intel/AMD)

### Available Images

| PHP Version | Image Tag | Base Image |
|-------------|-----------|------------|
| PHP 5.6 | `ghcr.io/nooblk-98/wordpess-docker:php56` | `ghcr.io/nooblk-98/php-docker-nginx:php56` |
| PHP 7.2 | `ghcr.io/nooblk-98/wordpess-docker:php72` | `ghcr.io/nooblk-98/php-docker-nginx:php72` |
| PHP 7.4 | `ghcr.io/nooblk-98/wordpess-docker:php74` | `ghcr.io/nooblk-98/php-docker-nginx:php74` |
| PHP 8.1 | `ghcr.io/nooblk-98/wordpess-docker:php81` | `ghcr.io/nooblk-98/php-docker-nginx:php81` |
| PHP 8.2 | `ghcr.io/nooblk-98/wordpess-docker:php82` | `ghcr.io/nooblk-98/php-docker-nginx:php82` |
| PHP 8.3 | `ghcr.io/nooblk-98/wordpess-docker:php83` | `ghcr.io/nooblk-98/php-docker-nginx:php83` |

## Requirements

- Docker Engine 20.10+
- Docker Compose v2
- Available ports: 8080 (HTTP) and 3306 (MariaDB) or custom port configuration

## Quick Start

### 1. Environment Configuration

Copy the example environment file and customize it:

```bash
cp env_example .env
```

### 2. Configuration Setup

Edit the `.env` file with your database credentials, admin user details, and desired plugins.

### 3. Deploy the Stack

```bash
docker compose up -d
```

### 4. Access Your Site

Navigate to http://localhost:8080 and log in with the admin credentials configured in your `.env` file.
## Configuration

### Environment Variables

Configure your deployment by editing the `.env` file. Key variables include:

| Variable | Description | Default |
|----------|-------------|---------|
| `PROJECT_NAME` | Container name prefix | `wordpress` |
| `MYSQL_HOST` | Database hostname | `mariadb` |
| `MYSQL_DATABASE` | Database name | `wordpress_database` |
| `MYSQL_USER` | Database username | `wordpress_user` |
| `MYSQL_PASSWORD` | Database password | Required |
| `MYSQL_ROOT_PASSWORD` | Database root password | Required |
| `WP_SITE_TITLE` | WordPress site title | `WordPress` |
| `WP_ADMIN_USER` | Admin username | `admin` |
| `WP_ADMIN_PASSWORD` | Admin password | Required |
| `WP_ADMIN_EMAIL` | Admin email address | Required |
| `WP_PLUGINS` | Space-separated plugin slugs | Optional |
| `UPLOAD_MAX` | Maximum upload file size | `256M` |
| `POST_MAX` | Maximum POST request size | `256M` |
| `MEMORY_LIMIT` | PHP memory limit | `512M` |

### Service Architecture

The default deployment includes:

- **WordPress Container**: Nginx + PHP-FPM + WP-CLI
- **MariaDB Container**: Database server (version 10.x)
- **Persistent Volumes**: 
  - `web_data`: WordPress files and uploads
  - `db_data`: Database storage

Default port mapping routes host port `8080` to container port `80`. Modify the `ports` section in `docker-compose.yml` to customize.

## Docker Compose Configuration

### Complete Example

```yaml
services:
  wordpress:
    image: ghcr.io/nooblk-98/wordpess-docker:php82
    container_name: ${PROJECT_NAME}
    restart: unless-stopped
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
    healthcheck:
      test: ["CMD-SHELL", "nc -z 127.0.0.1 80 || exit 1"]
      interval: 10s
      timeout: 3s
      retries: 10
      start_period: 30s

  mariadb:
    image: mariadb:10
    container_name: ${PROJECT_NAME}-db
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    volumes:
      - db_data:/var/lib/mysql
    ports:
      - "3306:3306"
    healthcheck:
      test: ["CMD-SHELL", "mysqladmin ping -h 127.0.0.1 -p$MYSQL_ROOT_PASSWORD || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 30s

  # Optional: Container health monitoring
  autoheal:
    image: willfarrell/autoheal
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock

volumes:
  db_data:
  web_data:
```

### Health Checks

Health checks are included to enable monitoring tools like Autoheal to automatically restart failed containers.

## Environment Configuration Example

Create a `.env` file in your project directory with the following configuration:

```env
# Project Configuration
PROJECT_NAME=wordpress

# Database Configuration
MYSQL_HOST=mariadb
MYSQL_DATABASE=wordpress_database
MYSQL_USER=wordpress_user
MYSQL_PASSWORD=changeMeStrong
MYSQL_ROOT_PASSWORD=changeMeRootStrong

# WordPress Configuration
WP_SITE_TITLE=WordPress
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=changeMeAdminStrong
WP_ADMIN_EMAIL=admin@example.com

# Plugin Configuration (space-separated slugs)
WP_PLUGINS="advanced-custom-fields temporary-login-without-password all-in-one-wp-migration"

# PHP Configuration
UPLOAD_MAX=256M
POST_MAX=256M
MEMORY_LIMIT=512M
```

**Note**: For external database connections, modify `MYSQL_HOST` to your database hostname and remove the `mariadb` service from the compose file.

## Deployment Options

### Using Bundled MariaDB Database

The default configuration includes a MariaDB container for database services:

1. Ensure your `.env` file contains the database configuration with `MYSQL_HOST=mariadb`
2. Deploy the complete stack:

```bash
docker compose up -d
```

The initial deployment automatically installs WordPress, creates the admin user, and installs any plugins specified in the `WP_PLUGINS` environment variable.

### Using External Database

For production environments with existing database infrastructure:

1. Configure external database connection in `.env`:

```env
MYSQL_HOST=db.myhost.com
MYSQL_DATABASE=external_db
MYSQL_USER=wp_user
MYSQL_PASSWORD=securepass
```

2. Remove or comment out the `mariadb` service in `docker-compose.yml`

3. Deploy WordPress service only:

```bash
docker compose up -d wordpress
```

Ensure your external database allows connections from the Docker host and verify credentials are correct.

## WordPress CLI Management

### WP-CLI Commands

Execute WordPress CLI commands within the container:

```bash
# Check WordPress version
docker compose exec wordpress wp core version --allow-root

# List installed plugins
docker compose exec wordpress wp plugin list --allow-root

# List WordPress users
docker compose exec wordpress wp user list --allow-root

# Update WordPress core
docker compose exec wordpress wp core update --allow-root
```

**Alternative User Context**: Use `-u www-data` for web user execution:
```bash
docker compose exec -u www-data wordpress wp plugin status
```

## Backup and Restore Operations

### Database Backup

Create a backup of your MariaDB database:

```bash
docker compose exec mariadb sh -c "mysqldump -u\$MYSQL_USER -p\$MYSQL_PASSWORD \$MYSQL_DATABASE" > backup.sql
```

### Database Restore

Restore from a backup file:

```bash
docker compose exec -i mariadb sh -c "mysql -u\$MYSQL_USER -p\$MYSQL_PASSWORD \$MYSQL_DATABASE" < backup.sql
```

### File System Backup

Backup WordPress files and uploads:

```bash
docker run --rm -v wordpess-docker_web_data:/src -v $PWD:/dst alpine sh -c "cd /src && tar czf /dst/wp-files.tgz ."
```

## Maintenance Operations

### Port Configuration

Modify the HTTP port by editing the `wordpress.ports` section in `docker-compose.yml`:

```yaml
ports:
  - "80:80"  # Direct port 80 mapping
```

### Image Updates

Update to the latest image version:

```bash
docker compose pull && docker compose up -d --no-deps wordpress
```

### Development Builds

Rebuild after making Dockerfile changes:

```bash
docker compose up -d --build
```

### Reset Installation

Remove the initialization flag to trigger fresh WordPress setup:

```bash
docker compose run --rm --entrypoint bash wordpress -lc "rm -f /var/www/html/.wp-init-done"
```

**Warning**: Complete reset (removes all data):

```bash
docker compose down -v
```

## Container Health Monitoring

### Autoheal Integration

Deploy automatic container restart functionality using [willfarrell/autoheal](https://github.com/willfarrell/docker-autoheal). Health checks are pre-configured in the provided Docker Compose examples.

For enhanced monitoring, use the dedicated autoheal configuration in `docker-compose.autoheal.yml` or implement the following:

```yaml
services:
  autoheal:
    image: willfarrell/autoheal
    restart: always
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock

  wordpress:
    labels:
      - autoheal=true
  mariadb:
    labels:
      - autoheal=true
```

**Note**: Autoheal functionality requires containers to define health check configurations.

## Troubleshooting

### Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| Database connection failed | Verify `MYSQL_*` environment variables and `MYSQL_HOST` configuration. For external databases, confirm network access and firewall rules. |
| Port binding error | Modify port mapping in `docker-compose.yml` (e.g., change `8080:80` to `9080:80`) |
| Plugin installation failure | Ensure `WP_PLUGINS` contains valid WordPress.org plugin slugs. Check container logs: `docker compose logs -f wordpress` |
| Incorrect site URL | Default installation uses `http://localhost:8080`. Update in WordPress Admin → Settings → General, or use WP-CLI |

### Debug Commands

Monitor container logs:
```bash
docker compose logs -f wordpress
docker compose logs -f mariadb
```

Check container health status:
```bash
docker compose ps
```

## Technical Details

### Configuration Management

- WordPress configuration is provided via `config/wp-config.php` and integrated into the container image
- Base runtime environment utilizes optimized Nginx and PHP-FPM configuration from `ghcr.io/nooblk-98/php-docker-nginx`

### Architecture

The solution implements a multi-container architecture with:
- **Application Layer**: Nginx reverse proxy with PHP-FPM processing
- **Database Layer**: MariaDB with persistent volume storage
- **Volume Management**: Separate volumes for application files and database storage

## Contributing

We welcome contributions to improve this WordPress Docker solution. Please submit issues and pull requests through the project repository.

### Development Guidelines

- Maintain compatibility across all supported PHP versions
- Ensure changes work with both bundled and external database configurations
- Test multi-architecture builds (ARM64/AMD64)
- Update documentation for any new features or configuration changes

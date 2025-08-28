## WordPress Docker (PHP 8.2, Nginx)

Production-ready WordPress packaged for Docker with sane defaults, WP‑CLI automation, and optional external DB support.

- Base image: `ghcr.io/nooblk-98/php-docker-nginx:php82`
- Image (this repo): `ghcr.io/nooblk-98/wordpess-docker:php82`
- Architectures: ARM64 and AMD64 (Apple Silicon, Graviton, Intel/AMD)

---

## Prerequisites

- Docker and Docker Compose v2
- Free ports: `8080` (HTTP) and `3306` (MariaDB) or adjust mappings
- Basic familiarity with `.env` files

---

## Quick Start

1) Copy files and create your `.env`.

```
cp env_example .env
```

2) Edit `.env` and set DB credentials, admin user, and plugin list.

3) Start the stack.

```
docker compose up -d
```

4) Open your site: http://localhost:8080

Login with the admin you set in `.env`.

---

## What You Get

- WordPress auto-install on first run (idempotent via `.wp-init-done`)
- WP‑CLI available in the container
- Plugin auto-install/activate from `.env`
- MariaDB bundled by default or connect to an external DB
- Persistent volumes for site and database data

---

## Configuration

Edit `.env` to control setup:

- `PROJECT_NAME`: Container name prefix (also used for DB container)
- `MYSQL_HOST`: Database host (default `mariadb` when using bundled DB)
- `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_ROOT_PASSWORD`: Database credentials
- `WP_SITE_TITLE`: WordPress site title
- `WP_ADMIN_USER`, `WP_ADMIN_PASSWORD`, `WP_ADMIN_EMAIL`: Admin account
- `WP_PLUGINS`: Space‑separated plugin slugs to preinstall and activate
- `UPLOAD_MAX`, `POST_MAX`, `MEMORY_LIMIT`: PHP limits

Reference example: `env_example:1`

---

## Compose Layout

Default services and volumes live in `docker-compose.yml:1`:

- `wordpress` (Nginx + PHP‑FPM + WP‑CLI)
- `mariadb` (10.x)
- Volumes: `web_data` (WordPress files), `db_data` (MariaDB data)

Port mapping: host `8080` → container `80`. Change by editing the `ports` section in `docker-compose.yml`.

---

## Full Docker Compose Example

Copy this into your project as `docker-compose.yml` (adjust ports and names as needed):

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
    labels:
      - autoheal=true # requires autoheal service below

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
    labels:
      - autoheal=true # optional

  # Optional: automatically restart unhealthy containers
  autoheal:
    image: willfarrell/autoheal
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock

volumes:
  db_data:
  web_data:
```

Note: Autoheal restarts containers that define a `HEALTHCHECK`. If your images don’t include one, consider adding a healthcheck in the compose file for best results.

---

## Full .env Example

Copy as `.env` in your project and adjust values:

```env
# Project/containers
PROJECT_NAME=wordpress

# Database (internal MariaDB or external host)
MYSQL_HOST=mariadb
MYSQL_DATABASE=wordpress_database
MYSQL_USER=wordpress_user
MYSQL_PASSWORD=changeMeStrong
MYSQL_ROOT_PASSWORD=changeMeRootStrong

# WordPress admin and site
WP_SITE_TITLE=WordPress
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=changeMeAdminStrong
WP_ADMIN_EMAIL=admin@example.com

# Pre-install plugin slugs (space-separated)
WP_PLUGINS="advanced-custom-fields temporary-login-without-password all-in-one-wp-migration"

# PHP limits
UPLOAD_MAX=256M
POST_MAX=256M
MEMORY_LIMIT=512M
```

Tip: For external DBs, set `MYSQL_HOST` to your DB hostname and comment out the `mariadb` service in the compose file.

---

## Use the Bundled MariaDB (Default)

1) Ensure `.env` has database values and `MYSQL_HOST=mariadb`.
2) Start the stack:

```
docker compose up -d
```

On first run the container installs WordPress, creates the admin user, and installs any plugins listed in `WP_PLUGINS`.

---

## Use an External Database (Optional)

1) Set the DB host and credentials in `.env`:

```
MYSQL_HOST=db.myhost.com
MYSQL_DATABASE=external_db
MYSQL_USER=wp_user
MYSQL_PASSWORD=securepass
```

2) Disable the bundled DB by commenting out `mariadb` in `docker-compose.yml`.

3) Recreate WordPress only:

```
docker compose up -d wordpress
```

Ensure the DB allows connections from the Docker host and the credentials are correct.

---

## WP‑CLI Usage

Run WP‑CLI inside the container:

```
docker compose exec wordpress wp core version --allow-root
docker compose exec wordpress wp plugin list --allow-root
docker compose exec wordpress wp user list --allow-root
```

Tip: Add `-u www-data` if you prefer the web user: `docker compose exec -u www-data wordpress wp ...`

---

## Backups and Restore

- Database backup (MariaDB volume):

```
docker compose exec mariadb sh -c "mysqldump -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE" > backup.sql
```

- Database restore:

```
docker compose exec -i mariadb sh -c "mysql -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE" < backup.sql
```

- Files backup (WordPress content): copy `web_data` volume. Example using a temporary helper:

```
docker run --rm -v wordpess-docker_web_data:/src -v $PWD:/dst alpine sh -c "cd /src && tar czf /dst/wp-files.tgz ."
```

---

## Common Tasks

- Change HTTP port: edit `wordpress.ports` in `docker-compose.yml` (e.g., `"80:80"`).
- Update image: `docker compose pull && docker compose up -d --no-deps wordpress`.
- Rebuild after Dockerfile changes: `docker compose up -d --build`.
- Reset first‑run install: remove the flag file in `web_data` volume (`/var/www/html/.wp-init-done`).

Example reset (removes the flag file only):

```
docker compose run --rm --entrypoint bash wordpress -lc "rm -f /var/www/html/.wp-init-done"
```

To fully reset, remove volumes: `docker compose down -v` (this deletes your data).

---

## Optional: Autoheal

You can add [willfarrell/autoheal](https://github.com/willfarrell/docker-autoheal) to auto‑restart unhealthy containers. In your compose file:

```
services:
  autoheal:
    image: willfarrell/autoheal
    restart: always
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock

  wordpress:
    labels:
      - autoheal=true
```

Note: Autoheal restarts containers only when they define a `HEALTHCHECK`.

---

## Troubleshooting

- Cannot connect to DB: verify `MYSQL_*` values and `MYSQL_HOST`; if external, confirm network access and firewall rules.
- Port already in use: change `8080:80` mapping in `docker-compose.yml`.
- Plugins not installing: ensure `WP_PLUGINS` contains valid slugs; check logs with `docker compose logs -f wordpress`.
- Wrong site URL: initial install uses `http://localhost:8080`. Change in WordPress Settings → General after first login, or update via WP‑CLI.

---

## Notes

- WordPress config is provided via `config/wp-config.php:1` and baked into the image.
- Base runtime (Nginx + PHP‑FPM) is provided by `ghcr.io/nooblk-98/php-docker-nginx:php82`.

---

## Contributing

Issues and PRs are welcome.

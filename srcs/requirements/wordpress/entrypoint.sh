#!/bin/bash

set -e

MARIADB_USER_PWD=$(cat /run/secrets/mariadb_user_pwd)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

if [ ! -f /var/www/html/wp-config.php ]; then
    wp config create --dbname=$MARIADB_DATABASE_NAME --dbuser=$MARIADB_USER_NAME --dbpass=$MARIADB_USER_PWD --dbhost=mariadb:3306 --allow-root
fi

if ! wp core is-installed --allow-root; then
    wp core install --url=$WP_SITE_URL --title="$WP_SITE_TITLE" --admin_user=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASSWORD --admin_email=$WP_ADMIN_EMAIL --allow-root
    wp user create $WP_USER_NAME $WP_USER_EMAIL --role=author --user_pass=$WP_USER_PASSWORD --allow-root
fi

exec php-fpm8.2 -F

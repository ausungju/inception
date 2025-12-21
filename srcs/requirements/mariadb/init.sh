#!/bin/bash

# Load secrets
MARIADB_ROOT_PASSWORD=$(cat /run/secrets/mariadb_root_password)
MARIADB_USER_PWD=$(cat /run/secrets/mariadb_user_pwd)

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "not found mysql database, initializing database..."
    mariadb-install-db --user=mysql > /dev/null 2>&1 || true

    mariadbd --user=mysql --skip-networking &
    TEMP_PID=$!

    until mariadb -e "SELECT 1" > /dev/null 2>&1; do
        sleep 1
    done

    mariadb <<-EOF
DROP DATABASE IF EXISTS \`${MARIADB_DATABASE_NAME}\`;
DROP USER IF EXISTS '${MARIADB_USER_NAME}'@'localhost';
DROP USER IF EXISTS '${MARIADB_USER_NAME}'@'%';

CREATE DATABASE \`${MARIADB_DATABASE_NAME}\`;
CREATE USER '${MARIADB_USER_NAME}'@'localhost' IDENTIFIED BY '${MARIADB_USER_PWD}';
CREATE USER '${MARIADB_USER_NAME}'@'%' IDENTIFIED BY '${MARIADB_USER_PWD}';

GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE_NAME}\`.* TO '${MARIADB_USER_NAME}'@'localhost';
GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE_NAME}\`.* TO '${MARIADB_USER_NAME}'@'%';
FLUSH PRIVILEGES;
EOF

    mariadb-admin shutdown
    wait $TEMP_PID
else
    echo "mysql database found, skipping initialization."
fi
echo "pre exec"
exec mariadbd --user=mysql

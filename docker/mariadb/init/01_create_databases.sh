#!/bin/sh
# create the test database (the mariadb image only supports one database in docker-compose)
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE_TEST;GRANT ALL PRIVILEGES ON $MYSQL_DATABASE_TEST.* TO '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD'; FLUSH PRIVILEGES;";

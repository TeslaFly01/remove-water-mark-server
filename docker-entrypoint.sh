#!/bin/bash
set -e

# 设置环境变量，请修改为你的应用
source /var/www/laravel-app/.env.example

# 等待数据库服务启动
while ! mysqladmin ping -h"$DB_HOST" -u"$DB_USERNAME" -p"$DB_PASSWORD" -P"${DB_PORT:-3306}" --silent; do
  echo "数据库服务还未响应，继续等待"
  sleep 3
done

# 初始化应用程序
# 这里可以自由发挥你要开机执行的命令
# [ -z "${APP_KEY}" ]
php artisan jwt:secret -f && php artisan mirage

# 启动应用程序
apache2-foreground
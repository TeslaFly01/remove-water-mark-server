# 我们使用 PHP 官方 Docker 镜像作为蓝本
FROM php:8.1.3-apache
# 官方的镜像基于 Debian 发行版构建，软件源由于网络问题可能会很慢，我们要使用国内镜像代替
# 将本项目下的 sources.list 文件复制到镜像的指定目录中
COPY sources.list /etc/apt/sources.list
# 执行 Debian 的软件升级
# 同时执行必要组件的安装
RUN apt-get update && \
    apt-get install -y git zip unzip libldap-2.4-2=2.4.47+dfsg-3+deb10u6 zlib1g=1:1.2.11.dfsg-1 libzip-dev libldap-dev mariadb-client --allow-downgrades && \
    apt-get clean \
# 这是 PHP Docker 安装扩展的特殊命令，这里是在 Docker 环境中的 PHP 安装扩展，如有需要可自行添加修改
RUN docker-php-ext-install -j$(nproc) zip ldap bcmath mysqli pdo_mysql sockets
# Apache 的重写模块
RUN a2enmod rewrite
# 从 Composer 官方镜像中复制最新的 Composer 执行文件
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
# 修改 Composer 为国内镜像源
RUN composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/
# 注意，这里是从代码仓库拉取你的 Laravel 应用代码至本地
# 请修改为你自己的代码仓库
RUN git clone https://github.com/TeslaFly01/remove-water-mark-server /var/www/laravel-app/
# 调整工作目录，跟着修改就行
WORKDIR /var/www/laravel-app/
# 执行 Composer 更新命令安装依赖
RUN composer update
# 执行文件权限相关命令
RUN chown -R www-data:www-data /var/www/chemex && \
    chmod -R 755 /var/www/chemex && \
    chmod -R 777 /var/www/chemex/storage
RUN rmdir /var/www/html && \
    ln -s /var/www/chemex/public /var/www/html
# 复制本项目下的 docker-entrypoint.sh 文件至 Docker 中
# 这个文件是 Docker 的入口点文件，是容器每次启动时都会执行的命令，可以简单的理解为开机启动项
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

entrypoint ["/docker-entrypoint.sh"]
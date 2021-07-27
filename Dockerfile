FROM registry.cn-hangzhou.aliyuncs.com/wuxyyin/docker-php-nginx:composer-swoole-kafka-7.3

# COPY files to image dir /app/
COPY . /app/

# COPY env file
COPY .env.example /app/.env

# COPY entrypoint to image
COPY docker/entrypoint.sh /

# Composer 并发安装
# RUN composer global require hirak/prestissimo
# Composer install
RUN cd /app && \
    php -d memory_limit=-1 /bin/composer install && \
    composer clearcache && \
    #env soft link
    mkdir /app/env && \
    mv /app/.env /app/env/.env && \
    ln -s /app/env/.env /app/.env && \
    chown -R nginx.nginx /app && \
    chmod -R 755 /app && \
    chmod -R 777 /app/storage /app/env && \
    chmod +x /entrypoint.sh && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# COPY new nginx config
COPY docker/nginx/conf.d/ /etc/nginx/conf.d/

# Configure supervisord
COPY docker/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
COPY docker/supervisor/conf.d/ /etc/supervisor/conf.d/

# Make the document root a volume
#VOLUME /app

# Switch to use a non-root user from here on
#USER nginx

# Add application
#WORKDIR /app

# Expose the port nginx is reachable on
#EXPOSE 80
EXPOSE 8081

# Let supervisord start nginx & php-fpm
#CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
ENTRYPOINT ["/entrypoint.sh"]

# Configure a healthcheck to validate that everything is up&running
#HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8081/fpm-ping

FROM debian:bookworm-slim

LABEL maintainer="seongkim"

RUN apt-get update && \
	apt-get install --no-install-recommends -y php8.2-fpm php8.2-mysql ca-certificates curl mariadb-client && \
	rm -rf /var/lib/apt/lists/*

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && \
	mv wp-cli.phar /usr/local/bin/wp

WORKDIR /var/www/html

RUN sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 0.0.0.0:9000|' /etc/php/8.2/fpm/pool.d/www.conf && \
	wp core download --path=/var/www/html --allow-root --locale=ko_KR && \
	chown -R www-data:www-data /var/www/html && \
	chmod -R 755 /var/www/html

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
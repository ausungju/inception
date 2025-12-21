FROM debian:bookworm-slim

LABEL maintainer="ausungju"

RUN apt-get update && \
	apt-get install --no-install-recommends -y mariadb-server && \
	rm -rf /var/lib/apt/lists/*

COPY mariadb.cnf /etc/mysql/mariadb.conf.d/99-custom.cnf

RUN rm -rf /var/lib/mysql/*
COPY init.sh /usr/local/bin/init-db.sh
RUN chmod +x /usr/local/bin/init-db.sh

ENTRYPOINT ["/usr/local/bin/init-db.sh"]

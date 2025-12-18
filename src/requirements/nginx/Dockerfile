FROM debian:bookworm-slim

LABEL maintainer="seongkim"

RUN apt-get update && \
    apt-get install  --no-install-recommends -y nginx procps && \
		rm -rf /var/lib/apt/lists/*

COPY ./config/nginx.conf /etc/nginx/nginx.conf
COPY ./config/ssl/ /etc/nginx/ssl/

ENTRYPOINT ["nginx", "-g", "daemon off;"]

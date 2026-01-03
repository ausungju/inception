data_dir =	./srcs/requirements/mariadb/data \
			./srcs/requirements/wordpress/src

secrets_file =	./secrets/mariadb_root_password.txt \
				./secrets/mariadb_user_pwd.txt \
				./secrets/wp_admin_password.txt \
				./secrets/wp_user_password.txt

all : up

secrets: 
	@mkdir -p secrets

	@for file in $(secrets_file); do \
		if [ ! -f $$file ]; then \
			openssl rand -base64 32 > $$file; \
		fi; \
	done

hosts:
	@cat /etc/hosts | grep "127.0.0.1 seongkim.42.fr" || sudo sh -c 'echo "hosts에 도메인 추가" && echo "127.0.0.1 seongkim.42.fr" >> /etc/hosts'

mkdir: 
	@mkdir -p $(data_dir)

build: secrets mkdir hosts
	@docker compose -f srcs/docker-compose.yml build

up: secrets mkdir hosts
	@docker compose -f srcs/docker-compose.yml up -d

down:
	@docker compose -f srcs/docker-compose.yml down -vt 0

restart: 
	@docker compose -f srcs/docker-compose.yml restart
	
clean : down
	@sudo rm -rf $(data_dir)

fclean: clean
	@docker system prune -a --volumes
	@rm -rf secrets

log :
	@docker compose -f srcs/docker-compose.yml logs -f --tail=100

status: 
	@bash -c '\
		NGINX_COMM=$$(docker compose -f srcs/docker-compose.yml exec nginx bash -c "ps -o comm= -p 1"); \
		MARIADB_COMM=$$(docker compose -f srcs/docker-compose.yml exec mariadb bash -c "ps -o comm= -p 1"); \
		WORDPRESS_COMM=$$(docker compose -f srcs/docker-compose.yml exec wordpress bash -c "ps -o comm= -p 1"); \
		\
		echo "┌───────────────────────────────────────────────────────────────────────────────┐"; \
		echo "│                             Inception Services                                │"; \
		echo "├───────────────┬───────────────────────┬───────────────────────┬───────────────┤"; \
		echo "│    Service    │         Name          │        Image          │     PID 1     │"; \
		echo "├───────────────┼───────────────────────┼───────────────────────┼───────────────┤"; \
		printf "│ %-13s │ %-21s │ %-21s │ %-13s │\n" "nginx" "nginx_container" "nginx:latest" "$$NGINX_COMM"; \
		printf "│ %-13s │ %-21s │ %-21s │ %-13s │\n" "mariadb" "mariadb_container" "mariadb:latest" "$$MARIADB_COMM"; \
		printf "│ %-13s │ %-21s │ %-21s │ %-13s │\n" "wordpress" "wordpress_container" "wordpress:latest" "$$WORDPRESS_COMM"; \
		echo "└───────────────┴───────────────────────┴───────────────────────┴───────────────┘"; \
	'

.PHONY: secrets hosts mkdir build up down restart remove-secrets clean fclean log status

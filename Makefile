
all : build up

secrets:
	@mkdir -p secrets
	@if [ ! -f secrets/mariadb_root_password.txt ]; then \
		openssl rand -base64 32 > secrets/mariadb_root_password.txt; \
		echo "Generated mariadb_root_password.txt"; \
	fi
	@if [ ! -f secrets/mariadb_user_pwd.txt ]; then \
		openssl rand -base64 32 > secrets/mariadb_user_pwd.txt; \
		echo "Generated mariadb_user_pwd.txt"; \
	fi
	@if [ ! -f secrets/wp_admin_password.txt ]; then \
		openssl rand -base64 32 > secrets/wp_admin_password.txt; \
		echo "Generated wp_admin_password.txt"; \
	fi
	@if [ ! -f secrets/wp_user_password.txt ]; then \
		openssl rand -base64 32 > secrets/wp_user_password.txt; \
		echo "Generated wp_user_password.txt"; \
	fi

build: secrets
	@docker compose -f src/docker-compose.yml build

up: secrets
	@docker compose -f src/docker-compose.yml up -d

down:
	@docker compose -f src/docker-compose.yml down -vt 0

restart: down up

rm:
	@docker compose -f src/docker-compose.yml rm -f

fclean : down rm
	@sudo rm -rf ./src/requirements/mariadb/data/*
	@sudo rm -rf ./src/requirements/wordpress/src/*

fclean-secrets: fclean
	@rm -rf secrets/*.txt
	@echo "Removed all secret files"
	
prune: fclean
	docker system prune -a --volumes

log :
	@docker compose -f src/docker-compose.yml logs -f --tail=100

status: 
	@bash -c '\
		NGINX_COMM=$$(docker compose -f src/docker-compose.yml exec nginx bash -c "ps -o comm= -p 1"); \
		MARIADB_COMM=$$(docker compose -f src/docker-compose.yml exec mariadb bash -c "ps -o comm= -p 1"); \
		WORDPRESS_COMM=$$(docker compose -f src/docker-compose.yml exec wordpress bash -c "ps -o comm= -p 1"); \
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
	
.PHONY: build up down restart stop rm fclean fclean-secrets prune ps exec log status secrets
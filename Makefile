ENV_NAME = mail_alias_platform

# Start all services in detached mode, rebuild images, recreate containers
up:
	@docker compose -p $(ENV_NAME) up -d --build --force-recreate

# Follow logs of all services
logs:
	@docker compose -p $(ENV_NAME) logs -f

# Start services in background without rebuild
bg:
	@docker compose -p $(ENV_NAME) up -d

# Stop and remove containers, networks
dn:
	@docker compose -p $(ENV_NAME) down

# Show status of all project containers
ps:
	@docker compose -p $(ENV_NAME) ps

# Full restart: stop and then start with rebuild
restart:
	@docker compose -p $(ENV_NAME) down
	@docker compose -p $(ENV_NAME) up -d --build

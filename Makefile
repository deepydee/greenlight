include .env
export

MIGRATIONS_PATH=./src/migrations
DSN=postgres://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=disable

up:
	docker compose up -d

down:
	docker compose down

migrate-up:
	docker compose exec app migrate \
		-path=$(MIGRATIONS_PATH) \
		-database="$(DSN)" up

migrate-down:
	docker compose exec app migrate \
		-path=$(MIGRATIONS_PATH) \
		-database="$(DSN)" down

migrate-version:
	docker compose exec app migrate \
		-path=$(MIGRATIONS_PATH) \
		-database="$(DSN)" version

migrate-goto:
	@read -p "Enter target version: " version; \
	docker compose exec app migrate \
	  -path=./src/migrations \
	  -database="postgres://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=disable" \
	  goto $$version

migrate-force:
	@read -p "Enter target version: " version; \
	docker compose exec app migrate \
		-path=$(MIGRATIONS_PATH) \
		-database="$(DSN)" force $$version



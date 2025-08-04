include .env
export

MIGRATIONS_PATH=./src/migrations
DSN=postgres://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=disable

# ==================================================================================== #
# HELPERS
# ==================================================================================== #

## help: print this help message
.PHONY: help
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'

.PHONY: confirm
confirm:
	@echo -n 'Are you sure? [y/N] ' && read ans && [ $${ans:-N} = y ]

# ==================================================================================== #
# DEVELOPMENT
# ==================================================================================== #

## up: start the app
.PHONY: up
up:
	docker compose up -d

## down: stop the app
.PHONY: down
down:
	docker compose down

## migrate-up: apply all up database migrations
.PHONY: migrate-up
migrate-up: confirm
	docker compose exec app migrate \
		-path=$(MIGRATIONS_PATH) \
		-database="$(DSN)" up

## migrate-down: rollback migrations
.PHONY: migrate-down
migrate-down: confirm
	docker compose exec app migrate \
		-path=$(MIGRATIONS_PATH) \
		-database="$(DSN)" down

## migrate-version: migrate to a specific version
.PHONY: migrate-version
migrate-version:
	docker compose exec app migrate \
		-path=$(MIGRATIONS_PATH) \
		-database="$(DSN)" version

## migrate-goto: migrate to a specific version
.PHONY: migrate-goto
migrate-goto:
	@read -p "Enter target version: " version; \
	docker compose exec app migrate \
	  -path=./src/migrations \
	  -database="postgres://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=disable" \
	  goto $$version

## migrate-force: force a migration
.PHONY: migrate-force
migrate-force: confirm
	@read -p "Enter target version: " version; \
	docker compose exec app migrate \
		-path=$(MIGRATIONS_PATH) \
		-database="$(DSN)" force $$version

# ==================================================================================== #
# QUALITY CONTROL
# ==================================================================================== #

## audit: tidy dependencies and format, vet and test all code
.PHONY: audit
audit:
	@echo 'Tidying and verifying module dependencies...'
	docker compose exec -T app go mod tidy
	docker compose exec -T app go mod verify
	@echo 'Formatting code...'
	docker compose exec -T app go fmt ./...
	@echo 'Vetting code...'
	docker compose exec -T app go vet ./...
	staticcheck ./...
	@echo 'Running tests...'
	docker compose exec -T app go test -race -vet=off ./...



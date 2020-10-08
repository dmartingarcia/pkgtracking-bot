ndef = $(if $(value $(1)),,$(error $(1) not set))

.PHONY: build

default: help

attach: ## Attach to tty console from web server
attach: daemon
	docker attach sense-ng_app_1

build:
	docker-compose build

rebuild-dev: ## Generate entire development environment
rebuild-dev: clean rebuild db-prepare npm-prepare

build-dev: ## Generate entire development environment
build-dev: clean build db-prepare npm-prepare

clean: ## Clean project containers and volumes
	docker-compose down
	docker volume ls | grep "sense-ng" | awk '{ print $$2 }' | xargs docker volume rm || true

daemon: ## Start web server as daemon
daemon:
	docker-compose up -d app

db-prepare: ## Delete and re-create the database
	docker-compose run app mix do ecto.drop, ecto.create, ecto.migrate

npm-prepare: ## prepare npm dependencies
	docker-compose run app sh -c "cd assets && npm install"

help:
	@printf "\033[1mUsage:\033[0m\n\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

migrate: ## Apply migrations
	docker-compose run app mix ecto.migrate

rebuild: ## Rebuild project
	docker-compose build --no-cache --force-rm
	docker-compose run --rm app mix do deps.get, deps.compile

shell: ## Execute a bash console
	docker-compose run --service-ports --rm app sh

stop: ## Stop all processes
	docker-compose stop

up: ## Start rails server
up:
	docker-compose run --rm app rm -rf tmp/pids/server.pid
	docker-compose up app

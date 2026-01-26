compose = docker compose
inferno = run inferno
box_compose = docker compose -f compose.aidbox.yaml

.PHONY: pull build up stop down migrate setup run tests rubocop

pull:
	$(compose) pull

build:
	$(compose) build

up:
	$(compose) up

stop:
	$(compose) stop

down:
	$(compose) down

migrate:
	$(compose) $(inferno) bundle exec inferno migrate

setup: pull build migrate

run: build up

restart: stop down pull build migrate up

tests:
	$(compose) $(inferno) bundle exec rspec

rubocop:
	$(compose) $(inferno) rubocop

dev_stop:
	$(box_compose) stop

dev_down:
	$(box_compose) down

dev_build:
	$(box_compose) build

dev_pull:
	$(box_compose) pull

dev_up:
	$(box_compose) up

dev_migrate:
	$(box_compose) $(inferno) bundle exec inferno migrate

dev_setup: dev_pull dev_build dev_migrate

dev_restart: dev_stop dev_down dev_pull dev_build dev_migrate dev_up

dev_run: dev_pull dev_build dev_migrate dev_up
compose = docker compose
inferno = run inferno

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

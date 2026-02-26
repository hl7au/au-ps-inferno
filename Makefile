MODE ?= default
ifeq ($(MODE), default)
compose = docker compose
else ifeq ($(MODE), aidbox)
compose = docker compose -f compose.aidbox.yaml
endif
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

restart: stop down setup up

tests:
	$(compose) $(inferno) bundle exec rspec

rubocop:
	$(compose) $(inferno) rubocop

local_generate:
	bundle exec rake generator:generate

local_rubocop:
	rubocop . -A

dev_restart: stop down local_generate setup up

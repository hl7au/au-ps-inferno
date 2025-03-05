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

tests:
	$(compose) $(inferno) bundle exec rspec

rubocop:
	$(compose) $(inferno) rubocop

generate:
	sudo rm -rf lib/au_ps_inferno/generated/
	$(compose) $(inferno) bundle exec rake au_ps:generate
	$(compose) $(inferno) rubocop -A

generate_local:
	sudo rm -rf lib/au_ps_inferno/generated/
	bundle exec rake au_ps:generate
	rubocop -A .

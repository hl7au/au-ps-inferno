MODE ?= default
ifeq ($(MODE), default)
compose = docker compose
else ifeq ($(MODE), aidbox)
compose = docker compose -f compose.aidbox.yaml
endif
inferno = run inferno

.PHONY: pull build up stop down migrate setup run tests rubocop coverage test_coverage snapshot-tests snapshot-tests-update

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

snapshot-tests:
	$(compose) $(inferno) bundle exec rspec spec/integration/suite_100ballot_snapshots_spec.rb

snapshot-tests-update:
	$(compose) run -e UPDATE_SNAPSHOTS=1 inferno bundle exec rspec spec/integration/suite_100ballot_snapshots_spec.rb

rubocop:
	$(compose) $(inferno) rubocop

local_generate:
	rm -rf lib/au_ps_inferno/1.0.0-ballot
	bundle exec rake generator:generate

local_rubocop:
	rubocop . -A

local_generate_and_rubocop: local_generate local_rubocop

dev_restart: stop down local_generate setup up

check_unused_code:
	ruby -rruby_parser -S debride lib/au_ps_inferno/

coverage test_coverage:
	COVERAGE=1 bundle exec rspec --format progress --format html --out coverage/index.html

flog:
	flog . -lib/au_ps_inferno/1.0.0-ballot -spec/

flay:
	flay
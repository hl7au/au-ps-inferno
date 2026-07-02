MODE ?= default
ifeq ($(MODE), default)
compose = docker compose
else ifeq ($(MODE), aidbox)
compose = docker compose -f compose.aidbox.yaml
endif
inferno = run inferno
generated_paths = $(patsubst lib/au_ps_inferno/igs/%.tgz,lib/au_ps_inferno/%,$(wildcard lib/au_ps_inferno/igs/*.tgz))

.PHONY: pull build up stop down migrate setup run tests coverage rubocop snapshot-tests snapshot-tests-update

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
	$(compose) $(inferno) bundle exec rspec spec/unit

coverage:
	$(compose) run -e COVERAGE=1 inferno bundle exec rspec --format documentation

snapshot-tests:
	$(compose) $(inferno) bundle exec rspec spec/integration/suite_100ballot_snapshots_spec.rb

snapshot-tests-update:
	$(compose) run -e UPDATE_SNAPSHOTS=1 inferno bundle exec rspec spec/integration/suite_100ballot_snapshots_spec.rb

rubocop:
	$(compose) $(inferno) rubocop

rake_generate:
	$(compose) $(inferno) bundle exec rake generator:generate

rm_generated:
	rm -rf $(generated_paths)

get_deps:
	$(compose) $(inferno) bundle exec rake deps:get

generate: rm_generated get_deps rake_generate

rubocop_fix:
	$(compose) $(inferno) bundle exec rubocop . -A

clean_generated:
	rm -rf $(generated_paths)
	git restore --source=HEAD -- $(generated_paths)

generate_and_fix: build generate rubocop_fix

dev_restart: stop down build generate rubocop_fix setup up

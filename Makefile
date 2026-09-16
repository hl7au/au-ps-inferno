MODE ?= default
ifeq ($(MODE), default)
compose = docker compose
else ifeq ($(MODE), aidbox)
compose = docker compose -f compose.aidbox.yaml
endif
inferno = run inferno
generated_v1_path = lib/au_ps_inferno/1.0.0-ballot
generated_v1_preview_path = lib/au_ps_inferno/1.0.0
SUITE ?= au_ps_v100

.PHONY: pull build up stop down migrate setup run tests coverage rubocop snapshot-tests snapshot-tests-update snapshot-tool-install snapshot-tool-init snapshot-tool-run

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

restart: down setup up

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

rubocop_fix:
	$(compose) $(inferno) rubocop -A

rake_generate:
	$(compose) $(inferno) bundle exec rake generator:generate

rm_generated:
	rm -rf $(generated_v1_preview_path)

get_deps:
	$(compose) $(inferno) bundle exec rake deps:get

generate: rm_generated get_deps rake_generate

rubocop_fix:
	$(compose) $(inferno) bundle exec rubocop . -A

clean_generated:
	rm -rf $(generated_v1_preview_path)
	git restore --source=HEAD -- $(generated_v1_preview_path)

generate_and_fix: build generate rubocop_fix

dev_restart: stop down build generate rubocop_fix setup up

# inferno_snapshot_tool (https://github.com/projkov/inferno_snapshot_tool) lives in its own
# local bundle under snapshot_tool/, so it never becomes a dependency of the suite itself.
# Runs directly on the host — point snapshot_tool/inferno_snapshot.yml's inferno_base_url
# at wherever the au_ps_v100 suite is actually reachable before running these.
snapshot-tool-install:
	cd snapshot_tool && bundle install

snapshot-tool-init:
	cd snapshot_tool && bundle exec inferno_snapshot_tool init $(SUITE)

snapshot-tool-run:
	cd snapshot_tool && bundle exec inferno_snapshot_tool run $(SUITE)

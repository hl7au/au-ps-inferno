MODE ?= default
ifeq ($(MODE), default)
compose = docker compose
else ifeq ($(MODE), aidbox)
compose = docker compose -f compose.aidbox.yaml
endif
inferno = run inferno
IG_ARCHIVE ?= lib/au_ps_inferno/igs/hl7.fhir.au.ps-1.0.0.tgz
IG_PACKAGE ?= hl7.fhir.au.ps
# Archives are named "<package>-<version>.tgz" (the fhir_packages_manager convention); strip the
# package prefix back off to recover the bare IG version rm_generated/clean_generated operate on.
ig_version = $(patsubst $(IG_PACKAGE)-%,%,$(basename $(notdir $(IG_ARCHIVE))))
generated_version_path = lib/au_ps_inferno/generated/$(ig_version)
IG_REGISTRIES ?= -r https://packages.fhir.org -r https://packages.simplifier.net

.PHONY: pull build up stop down migrate setup run tests coverage rubocop snapshot-tests snapshot-tests-update pending generate_pending check_ig fetch_ig list_ig_versions sync_igs

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
	$(compose) run -e IG_ARCHIVE=$(IG_ARCHIVE) inferno bundle exec rake generator:generate

pending:
	$(compose) $(inferno) bundle exec rake generator:pending

rm_generated:
	rm -rf $(generated_version_path)

get_deps:
	$(compose) $(inferno) bundle exec rake deps:get

generate: rm_generated get_deps rake_generate

rubocop_fix:
	$(compose) $(inferno) bundle exec rubocop . -A

clean_generated:
	rm -rf $(generated_version_path)
	git restore --source=HEAD -- $(generated_version_path)

generate_and_fix: build generate rubocop_fix

dev_restart: stop down build generate rubocop_fix setup up

generate_pending: build
	@archives=$$($(compose) $(inferno) bundle exec rake generator:pending 2>/dev/null | grep '\.tgz$$' | sed 's#^/opt/inferno/##'); \
	if [ -z "$$archives" ]; then echo "No pending archives."; exit 0; fi; \
	for archive in $$archives; do \
		echo "=== Generating suite for $$archive ==="; \
		IG_ARCHIVE=$$archive $(MAKE) generate_and_fix || exit 1; \
	done

check_ig:
	$(compose) run --rm fhir_packages_manager check $(IG_PACKAGE) $(IG_REGISTRIES)

fetch_ig:
	$(if $(IG_PACKAGE_VERSION),,$(error IG_PACKAGE_VERSION is required, e.g. make fetch_ig IG_PACKAGE_VERSION=1.0.0 -- run make list_ig_versions to see available versions))
	$(compose) run --rm fhir_packages_manager fetch $(IG_PACKAGE)@$(IG_PACKAGE_VERSION) $(IG_REGISTRIES) -d /fhir_packages -i /fhir_packages_ignore.yml

list_ig_versions:
	$(compose) run --rm fhir_packages_manager list $(IG_PACKAGE) $(IG_REGISTRIES) -i /fhir_packages_ignore.yml

IG_SYNC_REGISTRIES ?= -r https://packages.simplifier.net

sync_igs:
	$(compose) run --rm fhir_packages_manager sync $(IG_PACKAGE) $(IG_SYNC_REGISTRIES) -d /fhir_packages -i /fhir_packages_ignore.yml

MODE ?= default
ifeq ($(MODE), default)
compose = docker compose
else ifeq ($(MODE), aidbox)
compose = docker compose -f compose.yaml -f compose.aidbox.yaml
endif
inferno = run inferno
IG_ARCHIVE ?= lib/au_ps_inferno/igs/hl7.fhir.au.ps-1.0.0.tgz
IG_PACKAGE ?= hl7.fhir.au.ps
ig_version = $(patsubst $(IG_PACKAGE)-%,%,$(basename $(notdir $(IG_ARCHIVE))))
generated_version_path = lib/au_ps_inferno/generated/$(ig_version)
IG_REGISTRIES ?= -r https://packages.fhir.org -r https://packages.simplifier.net

.PHONY: pull build up stop down migrate setup run restart tests coverage rubocop rake_generate pending rm_generated \
	generate rubocop_fix clean_generated generate_and_fix generate_pending sync_igs sync_and_generate

pull:
	$(compose) --profile tools pull

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
	$(compose) $(inferno) bundle exec rspec spec/unit spec/generator

coverage:
	$(compose) run -e COVERAGE=1 inferno bundle exec rspec --format documentation

rubocop:
	$(compose) $(inferno) rubocop

rake_generate:
	$(compose) run -e IG_ARCHIVE=$(IG_ARCHIVE) inferno bundle exec rake generator:generate

pending:
	$(compose) $(inferno) bundle exec rake generator:pending

rm_generated:
	rm -rf $(generated_version_path)

generate: rm_generated rake_generate

rubocop_fix:
	$(compose) $(inferno) bundle exec rubocop . -A

clean_generated: rm_generated
	git restore --source=HEAD -- $(generated_version_path)

generate_and_fix: build generate rubocop_fix

generate_pending: build
	@archives=$$($(compose) $(inferno) bundle exec rake generator:pending 2>/dev/null | grep '\.tgz$$'); \
	if [ -z "$$archives" ]; then echo "No pending archives."; exit 0; fi; \
	for archive in $$archives; do \
		echo "=== Generating suite for $$archive ==="; \
		IG_ARCHIVE=$$archive $(MAKE) generate_and_fix || exit 1; \
	done

sync_igs:
	$(compose) run --rm fhir_packages_manager sync $(IG_PACKAGE) $(IG_REGISTRIES) -d /fhir_packages -i /fhir_packages_ignore.yml

sync_and_generate: sync_igs generate_pending

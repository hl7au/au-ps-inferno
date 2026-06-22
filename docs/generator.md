# AU PS Inferno — Test Suite Generator

This document describes how the AU PS Inferno test suite is generated, how to run
the generator locally, and the results of a local reproducibility test.

> The test kit is **generated**, not hand-written. The `.rb` files under
> `lib/au_ps_inferno/<version>/` are build artifacts produced from the AU PS IG
> package plus the generator source in `lib/au_ps_inferno/generator/`. Do not
> edit generated files by hand — change the generator and regenerate.

## State of existing documentation

Before this file, the generation process was **only partially documented**:

- `README.md` covers the **CI path** ("How to Generate New Test Suites" → the
  *Generate Suite* GitHub Action) and the **development workflow** rule (don't
  commit generator changes and regenerated tests in the same PR).
- Nothing documented **how to run the generator locally**, what the moving parts
  are, or what is derived from the IG vs. hardcoded.

This document fills that gap. `docs/` previously contained only
`text-review-improvements.md`.

## How generation is wired

| Piece | Location | Role |
|-------|----------|------|
| Generator source | `lib/au_ps_inferno/generator/` | The bespoke generator (`Generator` class, `SuiteStructure`, templates, etc.) |
| Suite config | `inferno_suite_generator.config.json` | IG id/version, CapabilityStatement URLs, package path, tx server |
| IG packages | `lib/au_ps_inferno/igs/*.tgz` | The AU PS IG package(s) the suite is built from |
| External deps | `additional_resources/*.json` | Base/IPS StructureDefinitions referenced by the IG, fetched from `deps_urls.txt` |
| Rake task | `Rakefile` → `generator:generate` | Entry point; **hardcodes** the IG path |
| Make targets | `Makefile` → `generate`, `generate_and_fix` | Orchestrates rm + deps + generate (+ rubocop) in Docker |
| CI | `.github/workflows/generate-suite.yaml` | `workflow_dispatch` → `make generate_and_fix` → opens a PR |
| Shared gem | `inferno_suite_generator` (`hl7au/...`, ref `b7d3590…`) | Provides compat utilities the bespoke generator builds on |

### What the generator reads from the IG package (auto-derived)

- Composition section metadata: `short`, `min`, `max`, `required`, `mustSupport`,
  section `code`, allowed entry profiles — extracted in `metadata_manager.rb`.
- Mandatory / recommended / optional section bucketing.
- Must Support elements for the bundle, composition, and the referenced
  subject / author / custodian / attester.
- The suite **version folder name and class/ID suffixes** are derived from the
  package **filename** (`version_suffix.rb`): `1.0.0-preview.tgz` →
  `lib/au_ps_inferno/1.0.0-preview/`, suffix `100preview`. A plain `1.0.0.tgz`
  would yield folder `1.0.0` and suffix `100`.

### What is hardcoded in the generator (NOT derived from the IG)

These must be reviewed by hand when the IG changes materially:

- `generator/constants.rb` → `REQUIRED_PROFILES`: literal AU PS profile URLs.
- `generator/constants.rb` → `RESOURCES_FILTERS_MAPPING`: literal profile URLs and
  section discriminator codes (smoking-status SNOMED, pregnancy/alcohol LOINC,
  lab/imaging categories).
- `generator/suite_structure/definitions.rb`: the section-role groups and the
  subject/author/custodian/attester group shape, plus the three high-order
  "delivery mode" groups (static Bundle instance / retrieve via read or GET /
  generate via IPS `$summary`).

## How to run the generator locally

Prerequisites: Docker (the generator runs in the Ruby 3.3.6 image; the gemspec
requires Ruby ≥ 3.3.6, so local Ruby may be too old). ~10 GB RAM for Docker.

```bash
# 1. Build the image (installs gems via bundle install)
docker compose build inferno

# 2a. Full path — refreshes external deps and regenerates (matches CI):
make generate          # = rm_generated + get_deps + rake_generate
#   note: get_deps fetches StructureDefinitions over the network from deps_urls.txt

# 2b. Generator only (no network, deps already committed) — useful for a
#     reproducibility check without touching additional_resources:
docker compose run --no-deps --rm inferno bundle exec rake generator:generate

# 3. (CI also runs) auto-fix style on the generated files:
make generate_and_fix  # = build + generate + rubocop_fix
```

The `--no-deps` flag skips the postgres/redis services — the generator only needs
the Ruby env, the IG package, and `additional_resources/`.

## Local test performed

**Goal:** confirm the generator runs and that the committed suite is reproducible
from source (i.e. the checked-in `1.0.0-preview/` is exactly what the generator
produces today). **Nothing was pushed.**

1. `docker compose build inferno` — succeeded.
2. `docker compose run --no-deps --rm inferno bundle exec rake generator:generate`
   — succeeded; regenerated all 104 `.rb` files under
   `lib/au_ps_inferno/1.0.0-preview/`.
3. `git status` — **zero changes to tracked files.**

### Result: fully reproducible

Regenerating from the committed `1.0.0-preview.tgz` produced **byte-identical**
output to what is checked in (0 modified, 0 added, 0 deleted). The committed
generated suite is in sync with the generator source and the IG package.

### Expected warnings (benign)

The run prints lines like:

```
StructureDefinition resource not found for profile
http://hl7.org/fhir/StructureDefinition/Observation. Add these resources as extra
bundle to the IG generator. Or your Inferno suite may work incorrectly.
```

These come from the shared generator walking profile references that aren't in the
AU PS package (base R4 / unused IPS profiles). They are **not fatal** — the run
completes, the AU PS suite does not depend on those profiles, and the output is
reproducible. The IPS/base profiles the suite *does* need are supplied via
`additional_resources/` (loaded successfully, e.g. `Observation-*-uv-ips`,
`DiagnosticReport-uv-ips`, the base `observation.profile.json`, etc.).

## Implications for an R1 `1.0.0` release

Generating the R1 suite is **"bump the pointers + regen + review the hardcoded
bits"**, not zero-touch:

1. **Pointer edits (mechanical):**
   - `inferno_suite_generator.config.json` → `version`, `package_archive_path`,
     `cs_version_specific_url`, `link`.
   - `Rakefile` → the `generator:generate` task hardcodes
     `lib/au_ps_inferno/igs/1.0.0-preview.tgz`.
   - `Makefile` → `generated_v1_preview_path` / `rm_generated` / `clean_generated`
     reference the `1.0.0-preview` folder.
   - Commit the new `1.0.0.tgz` into `lib/au_ps_inferno/igs/`.
2. **Auto-derived (free):** section content, cardinality, Must Support changes
   *inside existing profiles* flow through on regen. The version suffix logic
   handles a non-preview `1.0.0` cleanly (folder `1.0.0`, suffix `100`).
3. **Manual review required:** diff R1 against the hardcoded knowledge in
   `constants.rb` (`REQUIRED_PROFILES`, `RESOURCES_FILTERS_MAPPING`) and
   `suite_structure/definitions.rb`. New/renamed profiles, changed slicing codes,
   or a reshaped Composition (new roles/sections) need generator code edits before
   regenerating.

> Contrast with au-core (`au-fhir-core-inferno`): it is driven purely by config
> JSON against the *stock* shared generator (REST search/read tests from a
> CapabilityStatement + SearchParameters) with no hardcoded profile/code
> constants, so its version bumps are closer to zero-touch. AU PS needs the
> bespoke generator because it is a **document/Bundle IG**, not a REST-API IG.

## Notes

- Both kits are deployed via the `au-fhir-inferno` platform repo, which loads
  `au_ps_inferno` and `au_core_test_kit` as gems (pinned by git ref).
- The README's "auto-detect new releases and download all archives" description is
  aspirational; the actual pipeline regenerates the single configured/hardcoded
  version, kicked off manually via the *Generate Suite* workflow.

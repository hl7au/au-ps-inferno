# Changelog

## [1.0.1] - 2026-09-03

- Relax the `inferno_core` dependency from `~> 1.0.6` to `>= 1.0.6`. The tilde pin resolved to `>= 1.0.6, < 1.1.0` and was the only cap on `inferno_core` anywhere in the dependency tree, so it held every host application on 1.0.x. The kit uses only the public validation DSL (`resource_is_valid?`), which is unchanged through 1.4.x.

### Changed

- Split the Composition metadata out of `metadata.yaml` into `composition_metadata.yaml` and read it through `CompositionMetadataManager`, and regenerate the suite against the reworked generator. The generator itself was restructured (`metadata_producer.rb` replaces most of `metadata_manager.rb` and `ig_resources_extractor.rb`), and a workflow now syncs the IG package and regenerates the suite.

### Added

- Warn when the Problems, Allergies, or Medications section uses `Composition.section.emptyReason = nilknown` instead of an explicit negation code on the section's entry resource (e.g. `AllergyIntolerance.code = 716186003 |No known allergy|`), the pattern AU PS prefers over `emptyReason`. This is an advisory warning, not a failure.
- Include the section's narrative (`Composition.section.text`), converted from HTML to Markdown, in the Must Support element population message for each section. The HTML is sanitized first (stripping scripts, styles, and other unsafe or non-display markup, including `img` tags) so untrusted narrative content can't inject anything unsafe into the test report.

### Fixed

- Select the Australian SNOMED CT edition for validation instead of the validator's International default. The AU terminology server carries only the Australian edition, so the default made every SNOMED lookup fail and caused valid codes to be reported as absent from their value sets. Validating the AU PS `aups-basicsummary` example against `tx.dev.hl7.org.au` drops from 28 warnings and 19 information messages to 8 and 9, and removes a spurious error on the contained Medication's AMT code. Override with the `SNOMED_EDITION` environment variable.

## [1.0.0] - 2026-07-29

First stable release of the AU PS Inferno Test Kit, targeting AU PS Implementation Guide version 1.0.0. This release is functionally identical to 0.2.1; the version bump signals API and behaviour stability rather than new changes.

### Summary of changes since 0.1.0

- Bundle acquisition (pasted, retrieved from the FHIR server, or generated via `$summary`) is reported as its own test case, separate from Bundle Validation, so a failed retrieval no longer reads as a validation failure.
- Each top-level test group validates only the Bundle it acquired itself, using a per-group scratch key, so a Bundle acquired in one group can no longer leak into and be validated by another.
- Tests omit uniformly with one clear reason when a group's Bundle was not provided or acquired, instead of failing, passing vacuously, or skipping with inconsistent messages.
- Direct-URL Bundle retrieval goes through the Inferno HTTP DSL instead of raw `Net::HTTP`, so the request appears in the Requests tab and configured auth headers are honoured.
- The `$summary` acquisition test no longer skips when the server's CapabilityStatement omits the operation's declaration, since AU PS does not require it to be declared.
- The gemspec packages `.tgz`, `.yml` and `.yaml` files under `lib/`, so the Implementation Guide package is included in the built gem.
- The gem publishing workflow verifies the release tag matches the gem version, installs dependencies, and reliably builds and pushes the gem.

## [0.2.1] - 2026-07-21

### Fixed

- The gemspec now packages `.tgz`, `.yml` and `.yaml` files under `lib/`, so the Implementation Guide package is no longer missing from the built gem.

## [0.2.0] - 2026-07-21

### Changed

- Bundle acquisition (pasted, retrieved from the FHIR server, or generated via `$summary`) is now reported as its own test case, separate from Bundle Validation, so a failed retrieval no longer reads as a validation failure.
- Each top-level test group now validates only the Bundle it acquired itself; previously groups shared a single scratch key, so a Bundle acquired in one group could leak into and be validated by another.
- Tests now omit uniformly with one clear reason when a group's Bundle was not provided or acquired, instead of failing, passing vacuously, or skipping with inconsistent messages.
- Retitled acquisition tests to state what is being tested (e.g. "Bundle is retrievable from the FHIR server") rather than the action performed.
- Aligned inconsistent omit-reason wording across the Capability Statement group's tests.

### Fixed

- Direct-URL Bundle retrieval now goes through the Inferno HTTP DSL instead of raw `Net::HTTP`, so the request appears in the Requests tab and configured auth headers are honoured.
- The `$summary` acquisition test no longer skips when the server's CapabilityStatement omits the operation's declaration, since AU PS does not require it to be declared.
- Fixed the gem publishing workflow to verify the release tag matches the gem version, install dependencies, and reliably build and push the gem.
- Renamed the gemspec file to match the gem name and removed the RubyGems MFA requirement.

## [0.1.0] - 2026-07-06

### Added

- Initial release of the AU PS Inferno Test Kit, targeting AU PS Implementation Guide version 1.0.0.

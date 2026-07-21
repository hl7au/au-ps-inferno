# Changelog

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

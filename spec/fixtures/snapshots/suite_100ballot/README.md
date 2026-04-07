# `suite_100ballot` snapshots

These snapshots validate the normalized Inferno summary output for `suite_100ballot`
against a fixed set of AU PS bundle URLs.

## Run snapshot tests

- `docker compose run inferno bundle exec rspec spec/integration/suite_100ballot_snapshots_spec.rb`
- or `make snapshot-tests`
- optional override for execution command:
  - `SNAPSHOT_INFERNO_EXECUTE_COMMAND="docker compose run inferno bundle exec inferno execute" ...`

## Update snapshots (intentional changes only)

- `UPDATE_SNAPSHOTS=1 docker compose run inferno bundle exec rspec spec/integration/suite_100ballot_snapshots_spec.rb`
- or `make snapshot-tests-update`

## Normalization behavior

The spec keeps only the deterministic summary section:

- starts at the line containing `Test Results:`
- ends at the final separator line (`====...`)
- removes blank lines
- normalizes line endings to `\n`
- strips ANSI color codes

## When to expect snapshot changes

Snapshot changes are expected when:

- Inferno test logic/status behavior changes
- suite/group naming changes
- upstream AU PS bundle content causes different pass/fail/skip/error results

Snapshot changes should be reviewed in code review like any other test fixture.

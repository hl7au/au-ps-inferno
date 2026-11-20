# frozen_string_literal: true

require_relative 'au_ps_inferno/ci_build_suites'

# One suite per released AU PS IG version. scripts/sync_ig_and_generate_suite.rb adds a
# require here when it scaffolds a newly released version.
require_relative 'au_ps_inferno/suite/au_ps_v100'

# The ci-build suite tracks the AU PS CI build on build.fhir.org and is regenerated as the
# CI build changes, so only environments that opt in with INFERNO_CI_BUILD_SUITES=true load it.
# It lives only on the ci-build branch, which the Refresh CI Build Suite workflow maintains;
# master and gems built from it carry the tooling but not the suite, so the flag alone is
# not enough to load it.
require AUPSTestKit::CIBuildSuites::SUITE_FILE if AUPSTestKit::CIBuildSuites.load?

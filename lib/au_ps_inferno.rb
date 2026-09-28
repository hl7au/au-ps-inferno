# frozen_string_literal: true

require_relative 'au_ps_inferno/ci_build_suites'

# One suite per released AU PS IG version. scripts/sync_ig_and_generate_suite.rb adds a
# require here when it scaffolds a newly released version.
require_relative 'au_ps_inferno/suite/au_ps_v100'

# The suite tracking the AU PS CI build, loaded only when INFERNO_CI_BUILD_SUITES=true.
require_relative 'au_ps_inferno/suite/au_ps_ci_build' if AUPSTestKit::CIBuildSuites.enabled?

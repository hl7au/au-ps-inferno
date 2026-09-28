# frozen_string_literal: true

require_relative 'au_ps_suite_definition'

module AUPSTestKit
  # Test suite tracking the continuous-integration build of the AU PS Implementation Guide
  # (https://build.fhir.org/ig/hl7au/au-fhir-ps/). lib/au_ps_inferno.rb loads it only when
  # INFERNO_CI_BUILD_SUITES=true. rake au_ps:ci_build:refresh regenerates its metadata and
  # IG_VERSION when the CI build changes. The suite id is fixed (au_ps_ci_build), so sessions
  # and the places that list the suite by id survive a CI version bump.
  class AUPSCIBuildSuite < Inferno::TestSuite
    IG_VERSION = '1.0.1-ci-build'
    # The validator resolves #current from build.fhir.org itself and refreshes it when the
    # CI build's package.manifest.json date changes.
    SUITE_VERSION = SuiteVersion.new(key: 'ci-build', ig_version: IG_VERSION, suite_id: :au_ps_ci_build,
                                     validator_package: "#{SuiteVersion::PACKAGE_ID}#current")

    extend AUPSSuiteDefinition

    define_au_ps_suite(
      SUITE_VERSION,
      title: "AU PS #{IG_VERSION} Test Suite (tracks the CI build)",
      description: 'Validates AU PS (Australian Primary Care and Shared Health) bundles, ' \
                   'compositions, sections, and server CapabilityStatement support against the ' \
                   'continuous-integration build of the implementation guide ' \
                   '(https://build.fhir.org/ig/hl7au/au-fhir-ps/), not a published release. ' \
                   'The suite tracks the CI build and is regenerated whenever the build changes; ' \
                   'a regeneration can change test ids, so sessions started before it may stop ' \
                   'rendering. Use a released AU PS suite for conformance results.'
    )
  end
end

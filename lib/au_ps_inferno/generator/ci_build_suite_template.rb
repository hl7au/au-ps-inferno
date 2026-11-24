# frozen_string_literal: true

require_relative '../suite_version'

module AUPSTestKit
  # Source of the suite class for the CI build (+lib/au_ps_inferno/suite/au_ps_ci_build.rb+).
  #
  # Released versions have a hand-written suite class whose +IG_VERSION+ the generator rewrites.
  # The CI build suite lives only on the ci-build branch, which starts from master without it, so
  # the generator writes the whole class from this template each time it generates the CI build.
  # Only +IG_VERSION+ varies: the suite id stays +au_ps_ci_build+ and the validator package stays
  # +hl7.fhir.au.ps#current+ whatever the package version.
  module CIBuildSuiteTemplate
    # The generated file, with +<ig_version>+ standing for the package version.
    SOURCE = <<~'RUBY'
      # frozen_string_literal: true

      require_relative 'au_ps_suite_definition'

      module AUPSTestKit
        # Test suite tracking the continuous-integration build of the AU PS Implementation Guide
        # (https://build.fhir.org/ig/hl7au/au-fhir-ps/). lib/au_ps_inferno.rb loads it only when
        # INFERNO_CI_BUILD_SUITES=true. rake au_ps:ci_build:refresh regenerates this file and its
        # metadata when the CI build changes, from lib/au_ps_inferno/generator/ci_build_suite_template.rb
        # on master; edit the template, not this file. The suite id is fixed (au_ps_ci_build), so
        # sessions and the places that list the suite by id survive a CI version bump.
        class AUPSCIBuildSuite < Inferno::TestSuite
          IG_VERSION = '<ig_version>'
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
    RUBY

    # @param ig_version [String] the CI build package version, such as +1.0.1-ci-build+
    # @return [String] the Ruby source of the CI build suite class
    def self.source(ig_version)
      unless SuiteVersion::VERSION_PATTERN.match?(ig_version.to_s)
        raise ArgumentError, "Not an IG package version: #{ig_version.inspect}"
      end

      SOURCE.sub("'<ig_version>'") { "'#{ig_version}'" }
    end
  end
end

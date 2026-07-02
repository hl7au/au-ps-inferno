# frozen_string_literal: true

require_relative 'au_ps_composition_undefined_sections/suite_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_undefined_sections_sections_may_undefined'

module AUPSTestKit
  # Automatically generated primitive group for AU PS Composition Undefined Sections
  class AUPSSuiteGenerateAuPsUsingIpsSummaryValidationTestsAuPsCompositionUndefinedSections100ballot < Inferno::TestGroup
    title 'AU PS Composition Undefined Sections'
    description 'Verify the undefined sections are correctly populated in the AU PS Composition resource.'
    id :suite_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_undefined_sections_100ballot

    optional

    run_as_group

    test from: :suite_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_undefined_sections_sections_may_undefined_100ballot
  end
end

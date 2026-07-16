# frozen_string_literal: true

require_relative 'suite_generate_au_ps_using_ips_summary_validation_tests_bundle_generate'

module AUPSTestKit
  # Automatically generated primitive group for Generate AU PS Bundle using $summary
  class AUPSSuiteGenerateAuPsUsingIpsSummaryValidationTestsBundleAcquisition < Inferno::TestGroup
    title 'Generate AU PS Bundle using $summary'
    description 'Invokes the IPS $summary operation on the FHIR server and stores the returned Bundle for the validation tests in this group.'
    id :suite_generate_au_ps_using_ips_summary_validation_tests_bundle_acquisition

    run_as_group

    test from: :suite_generate_au_ps_using_ips_summary_validation_tests_bundle_generate
  end
end

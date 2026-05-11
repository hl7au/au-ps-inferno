# frozen_string_literal: true

require_relative 'bundle_validation/suite_100preview_generate_au_ps_using_ips_summary_validation_tests_bundle_validation_bundle_valid'

require_relative 'bundle_validation/suite_100preview_generate_au_ps_using_ips_summary_validation_tests_bundle_validation_bundle_valid_ips'

module AUPSTestKit
  # Automatically generated primitive group for Bundle Validation
  class AUPSSuite100previewGenerateAuPsUsingIpsSummaryValidationTestsBundleValidation < Inferno::TestGroup
    title 'Bundle Validation'
    description 'Validates that the bundle conforms to the Bundle profiles.'
    id :suite_100preview_generate_au_ps_using_ips_summary_validation_tests_bundle_validation

    run_as_group

    test from: :suite_100preview_generate_au_ps_using_ips_summary_validation_tests_bundle_validation_bundle_valid

    test from: :suite_100preview_generate_au_ps_using_ips_summary_validation_tests_bundle_validation_bundle_valid_ips
  end
end

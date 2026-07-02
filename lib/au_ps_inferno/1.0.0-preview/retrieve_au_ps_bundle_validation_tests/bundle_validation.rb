# frozen_string_literal: true

require_relative 'bundle_validation/suite_retrieve_au_ps_bundle_validation_tests_bundle_validation_bundle_valid'

require_relative 'bundle_validation/suite_retrieve_au_ps_bundle_validation_tests_bundle_validation_bundle_valid_ips'

module AUPSTestKit
  # Automatically generated primitive group for Bundle Validation
  class AUPSSuiteRetrieveAuPsBundleValidationTestsBundleValidation100preview < Inferno::TestGroup
    title 'Bundle Validation'
    description 'Validates that the bundle conforms to the Bundle profiles.'
    id :suite_retrieve_au_ps_bundle_validation_tests_bundle_validation_100preview

    run_as_group

    test from: :suite_retrieve_au_ps_bundle_validation_tests_bundle_validation_bundle_valid_100preview

    test from: :suite_retrieve_au_ps_bundle_validation_tests_bundle_validation_bundle_valid_ips_100preview
  end
end

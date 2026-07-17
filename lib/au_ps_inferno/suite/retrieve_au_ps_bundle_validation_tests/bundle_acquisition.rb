# frozen_string_literal: true

require_relative 'suite_retrieve_au_ps_bundle_validation_tests_bundle_retrieve'

module AUPSTestKit
  # Automatically generated primitive group for Retrieve AU PS Bundle
  class AUPSSuiteRetrieveAuPsBundleValidationTestsBundleAcquisition < Inferno::TestGroup
    title 'Retrieve AU PS Bundle'
    description 'Retrieves the document Bundle using a Bundle read interaction or a direct HTTP GET request and stores it for the validation tests in this group.'
    id :suite_retrieve_au_ps_bundle_validation_tests_bundle_acquisition

    run_as_group

    test from: :suite_retrieve_au_ps_bundle_validation_tests_bundle_retrieve
  end
end

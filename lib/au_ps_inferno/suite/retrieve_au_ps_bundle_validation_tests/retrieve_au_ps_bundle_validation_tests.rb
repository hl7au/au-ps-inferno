# frozen_string_literal: true

require_relative 'bundle_acquisition'
require_relative '../../utils/common_inputs_module'

module AUPSTestKit
  # Automatically generated high order group for Retrieve AU PS Bundle validation tests
  class AUPSSuiteRetrieveAuPsBundleValidationTests < Inferno::TestGroup
    title 'Retrieve Bundle'
    description 'Retrieve document Bundle using Bundle read interaction or other HTTP GET request and verify response is valid AU PS Bundle'
    id :suite_retrieve_au_ps_bundle_validation_tests

    run_as_group

    CommonInputsModule.shared_inputs(self)

    group from: :suite_retrieve_au_ps_bundle_validation_tests_bundle_acquisition

  end
end

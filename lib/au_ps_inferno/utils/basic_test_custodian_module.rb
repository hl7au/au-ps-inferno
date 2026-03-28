# frozen_string_literal: true

require_relative 'basic_test_custodian_resource'
require_relative 'basic_test_custodian_metadata'
require_relative 'basic_test_custodian_ms_elements'
require_relative 'basic_test_custodian_ms_subelements'
require_relative 'basic_test_custodian_identifier_slices'
require_relative 'basic_test_custodian_tests'

module AUPSTestKit
  # Composes Composition.custodian Must Support helpers for BasicTest.
  module BasicTestCustodianModule
    include BasicTestCustodianResource
    include BasicTestCustodianMetadata
    include BasicTestCustodianMsElements
    include BasicTestCustodianMsSubelements
    include BasicTestCustodianIdentifierSlices
    include BasicTestCustodianTests
  end
end

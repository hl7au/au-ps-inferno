# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'

module AUPSTestKit
  # Automatically generated primitive test for Must Support elements SHALL be populated if a value is known
  class AUPSSuiteRetrieveAuPsBundleValidationTestsAuPsCompositionAuthorMustSupportElementsShallBePopulatedIfAValueIsKnown < BasicTest
    title 'Must Support elements SHALL be populated if a value is known'
    description 'Must Support elements SHALL be populated if a value is known'
    id :suite_retrieve_au_ps_bundle_validation_tests_au_ps_composition_author_author_ms_elements

    run do
      ms_elements_populated_message('author')
    end
  end
end

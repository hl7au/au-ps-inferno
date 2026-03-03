# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'


module AUPSTestKit
  # Automatically generated primitive test for Optional Must Support elements SHALL be correctly populated if a value is known
  class AUPSSuite100ballotGenerateBundleUsingIpsSummaryValidationCompositionMustSupportElementsOptionalMustSupportElementsShallBeCorrectlyPopulatedIfAValueIsKnown < BasicTest
    title 'Optional Must Support elements SHALL be correctly populated if a value is known'
    description ''
    id :suite_100ballot_generate_bundle_using_ips_summary_validation_composition_must_support_elements_optional_must_support_elements_shall_be_correctly_populated_if_a_value_is_known
    
    optional
    
    
    run do
      
      validate_populated_elements_in_composition(["attester", "custodian", "identifier", "section"])
      
    end
    
  end
end

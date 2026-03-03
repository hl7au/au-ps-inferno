# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'


module AUPSTestKit
  # Automatically generated primitive test for Optional Must Support elements SHALL be correctly populated if a value is known
  class AUPSSuite100ballotGeneratedBundleIpsSummaryCompositionMustSupportElementsOptionalMustSupportElementsShallBeCorrectlyPopulatedIfAValueIsKnown < BasicTest
    title 'Optional Must Support elements SHALL be correctly populated if a value is known'
    description 'Verifies that optional Must Support elements in the Composition are correctly populated when data is known.'
    id :suite_100ballot_generated_bundle_ips_summary_composition_must_support_elements_optional_must_support_elements_shall_be_correctly_populated_if_a_value_is_known
    
    optional
    
    
    run do
      
      validate_populated_elements_in_composition(["attester", "custodian", "identifier", "section"])
      
    end
    
  end
end

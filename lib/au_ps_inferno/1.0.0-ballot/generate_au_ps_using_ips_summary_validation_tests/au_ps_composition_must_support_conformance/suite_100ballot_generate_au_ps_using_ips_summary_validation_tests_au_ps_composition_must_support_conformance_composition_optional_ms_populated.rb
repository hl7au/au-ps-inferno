# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'


module AUPSTestKit
  # Automatically generated primitive test for Optional Must Support elements are correctly populated
  class AUPSSuite100ballotGenerateAuPsUsingIpsSummaryValidationTestsAuPsCompositionMustSupportConformanceOptionalMustSupportElementsAreCorrectlyPopulated < BasicTest
    title 'Optional Must Support elements are correctly populated'
    description 'Optional Must Support elements SHALL be correctly populated if a value is known'
    id :suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_must_support_conformance_composition_optional_ms_populated
    
    
    run do
      
      validate_populated_elements_in_composition(["attester", "custodian", "identifier", "text", "event"], required: false)
      
    end
    
  end
end

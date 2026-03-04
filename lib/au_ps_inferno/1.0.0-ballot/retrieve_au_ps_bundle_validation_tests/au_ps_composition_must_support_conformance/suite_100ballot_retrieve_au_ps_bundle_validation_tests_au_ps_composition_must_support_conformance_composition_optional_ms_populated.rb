# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'


module AUPSTestKit
  # Automatically generated primitive test for Optional Must Support elements are correctly populated
  class AUPSSuite100ballotRetrieveAuPsBundleValidationTestsAuPsCompositionMustSupportConformanceOptionalMustSupportElementsAreCorrectlyPopulated < BasicTest
    title 'Optional Must Support elements are correctly populated'
    description 'Verifies that optional Must Support elements in the Composition are correctly populated when data is known.'
    id :suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_composition_must_support_conformance_composition_optional_ms_populated
    
    optional
    
    
    run do
      
      validate_populated_elements_in_composition(["attester", "custodian", "identifier", "section"])
      
    end
    
  end
end

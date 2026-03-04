# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'


module AUPSTestKit
  # Automatically generated primitive test for Must Support sub-elements of a complex element are correctly populated
  class AUPSSuite100ballotRetrieveAuPsBundleValidationTestsAuPsCompositionMustSupportConformanceMustSupportSubelementsOfAComplexElementAreCorrectlyPopulated < BasicTest
    title 'Must Support sub-elements of a complex element are correctly populated'
    description 'Verifies that Must Support sub-elements of complex elements are correctly populated when data is known.'
    id :suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_composition_must_support_conformance_composition_ms_subelements_populated
    
    optional
    
    
    run do
      
      validate_populated_elements_in_composition(["attester.party", "attester.time", "event.period", "section.emptyReason", "section.entry"])
      
    end
    
  end
end

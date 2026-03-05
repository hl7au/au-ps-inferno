# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'


module AUPSTestKit
  # Automatically generated primitive test for Must Support sub-elements of a complex element are correctly populated
  class AUPSSuite100ballotAuPsBundleInstanceAuPsCompositionMustSupportConformanceMustSupportSubelementsOfAComplexElementAreCorrectlyPopulated < BasicTest
    title 'Must Support sub-elements of a complex element are correctly populated'
    description 'Must Support sub-elements of a complex element SHALL be correctly populated if a value is known'
    id :suite_100ballot_au_ps_bundle_instance_au_ps_composition_must_support_conformance_composition_ms_subelements_populated
    
    optional
    
    
    run do
      
      validate_populated_elements_in_composition(["attester.party", "attester.time", "event.period", "section.emptyReason", "section.entry"])
      
    end
    
  end
end

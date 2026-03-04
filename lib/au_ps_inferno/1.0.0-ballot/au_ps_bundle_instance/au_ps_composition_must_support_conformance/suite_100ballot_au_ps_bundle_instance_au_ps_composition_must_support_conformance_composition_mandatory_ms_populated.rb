# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'


module AUPSTestKit
  # Automatically generated primitive test for Mandatory Must Support elements are correctly populated
  class AUPSSuite100ballotAuPsBundleInstanceAuPsCompositionMustSupportConformanceMandatoryMustSupportElementsAreCorrectlyPopulated < BasicTest
    title 'Mandatory Must Support elements are correctly populated'
    description 'Verifies that mandatory Must Support elements in the Composition can be populated when data is known and shareable.'
    id :suite_100ballot_au_ps_bundle_instance_au_ps_composition_must_support_conformance_composition_mandatory_ms_populated
    
    
    run do
      
      validate_populated_elements_in_composition(["author", "date", "section", "status", "subject", "title", "type"])
      
    end
    
  end
end

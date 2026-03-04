# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'


module AUPSTestKit
  # Automatically generated primitive test for Must Support slices are correctly populated
  class AUPSSuite100ballotRetrieveAuPsBundleValidationTestsAuPsCompositionMustSupportConformanceMustSupportSlicesAreCorrectlyPopulated < BasicTest
    title 'Must Support slices are correctly populated'
    description 'Verifies that optional Must Support slices are populated when data is known.'
    id :suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_composition_must_support_conformance_composition_optional_ms_slices
    
    optional
    
    
    run do
      
      validate_populated_slices_in_composition([{:path=>"event", :sliceName=>"careProvisioningEvent", :min=>0, :max=>"1", :mustSupport=>true}])
      
    end
    
  end
end

# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'


module AUPSTestKit
  # Automatically generated primitive test for Must Support slices are correctly populated
  class AUPSSuite100ballotAuPsBundleInstanceAuPsCompositionMustSupportConformanceMustSupportSlicesAreCorrectlyPopulated < BasicTest
    title 'Must Support slices are correctly populated'
    description 'Must Support slice careProvisioningEvent SHALL be populated if a value is known.'
    id :suite_100ballot_au_ps_bundle_instance_au_ps_composition_must_support_conformance_composition_optional_ms_slices
    
    optional
    
    
    run do
      
      validate_populated_slices_in_composition([{:path=>"event", :sliceName=>"careProvisioningEvent", :min=>0, :max=>"1", :mustSupport=>true, :mandatory_ms_sub_elements=>["period"], :optional_ms_sub_elements=>["code"]}])
      
    end
    
  end
end

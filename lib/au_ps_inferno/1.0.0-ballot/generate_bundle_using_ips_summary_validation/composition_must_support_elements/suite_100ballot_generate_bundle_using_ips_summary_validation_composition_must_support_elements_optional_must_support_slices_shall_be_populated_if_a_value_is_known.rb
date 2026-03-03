# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'


module AUPSTestKit
  # Automatically generated primitive test for Optional Must Support slices SHALL be populated if a value is known
  class AUPSSuite100ballotGenerateBundleUsingIpsSummaryValidationCompositionMustSupportElementsOptionalMustSupportSlicesShallBePopulatedIfAValueIsKnown < BasicTest
    title 'Optional Must Support slices SHALL be populated if a value is known'
    description ''
    id :suite_100ballot_generate_bundle_using_ips_summary_validation_composition_must_support_elements_optional_must_support_slices_shall_be_populated_if_a_value_is_known
    
    optional
    
    
    run do
      
      validate_populated_slices_in_composition([{:path=>"event", :sliceName=>"careProvisioningEvent", :min=>0, :max=>"1", :mustSupport=>true}])
      
    end
    
  end
end

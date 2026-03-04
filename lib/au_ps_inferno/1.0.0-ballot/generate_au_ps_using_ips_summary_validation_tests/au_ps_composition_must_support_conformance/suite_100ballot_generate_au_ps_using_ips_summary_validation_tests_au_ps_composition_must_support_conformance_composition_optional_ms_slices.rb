# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'


module AUPSTestKit
  # Automatically generated primitive test for Optional Must Support slices SHALL be populated if a value is known
  class AUPSSuite100ballotGenerateAuPsUsingIpsSummaryValidationTestsAuPsCompositionMustSupportConformanceOptionalMustSupportSlicesShallBePopulatedIfAValueIsKnown < BasicTest
    title 'Optional Must Support slices SHALL be populated if a value is known'
    description 'Verifies that optional Must Support slices are populated when data is known.'
    id :suite_100ballot_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_must_support_conformance_composition_optional_ms_slices
    
    optional
    
    
    run do
      
      validate_populated_slices_in_composition([{:path=>"event", :sliceName=>"careProvisioningEvent", :min=>0, :max=>"1", :mustSupport=>true}])
      
    end
    
  end
end

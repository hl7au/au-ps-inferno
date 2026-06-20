# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'


module AUPSTestKit
  # Automatically generated primitive test for Must Support sliced elements are correctly populated
  class AUPSSuite100previewGenerateAuPsUsingIpsSummaryValidationTestsAuPsCompositionConformanceTestsMustSupportSlicedElementsAreCorrectlyPopulated < BasicTest
    title 'Must Support sliced elements are correctly populated'
    description 'Must Support sliced elements SHALL be populated if a value is known.'
    id :suite_100preview_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_conformance_tests_composition_optional_ms_slices
    
    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../1.0.0-preview/metadata.yaml', __dir__))
    end
    
    run do
      
      validate_populated_slices_in_composition([{:path=>"event", :sliceName=>"careProvisioningEvent", :min=>0, :max=>"1", :mustSupport=>true, :mandatory_ms_sub_elements=>["period"], :optional_ms_sub_elements=>["code"]}])
      
    end
    
  end
end

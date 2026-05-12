# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'


module AUPSTestKit
  # Automatically generated primitive test for Optional Must Support elements are correctly populated
  class AUPSSuite100previewGenerateAuPsUsingIpsSummaryValidationTestsAuPsCompositionMustSupportConformanceOptionalMustSupportElementsAreCorrectlyPopulated < BasicTest
    title 'Optional Must Support elements are correctly populated'
    description 'Optional Must Support elements SHALL be correctly populated if a value is known'
    id :suite_100preview_generate_au_ps_using_ips_summary_validation_tests_au_ps_composition_must_support_conformance_composition_optional_ms_populated
    
    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../1.0.0-preview/metadata.yaml', __dir__))
    end
    
    run do
      
      validate_optional_ms_elements_in_composition
      
    end
    
  end
end

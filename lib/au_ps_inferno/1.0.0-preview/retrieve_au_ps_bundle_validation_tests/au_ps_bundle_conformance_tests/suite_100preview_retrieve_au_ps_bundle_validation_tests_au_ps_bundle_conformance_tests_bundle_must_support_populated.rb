# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'


module AUPSTestKit
  # Automatically generated primitive test for AU PS Bundle Must Support elements are correctly populated
  class AUPSSuite100previewRetrieveAuPsBundleValidationTestsAuPsBundleConformanceTestsAuPsBundleMustSupportElementsAreCorrectlyPopulated < BasicTest
    title 'AU PS Bundle Must Support elements are correctly populated'
    description 'Must Support elements SHALL be included if a value is known and allowed to be shared.'
    id :suite_100preview_retrieve_au_ps_bundle_validation_tests_au_ps_bundle_conformance_tests_bundle_must_support_populated
    
    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../1.0.0-preview/metadata.yaml', __dir__))
    end
    
    run do
      
      bundle_mandatory_ms_elements_info
      
    end
    
  end
end

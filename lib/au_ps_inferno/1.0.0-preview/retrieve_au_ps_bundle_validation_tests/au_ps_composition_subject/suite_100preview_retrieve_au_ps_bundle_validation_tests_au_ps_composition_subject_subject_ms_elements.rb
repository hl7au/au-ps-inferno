# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'


module AUPSTestKit
  # Automatically generated primitive test for Must Support elements SHALL be populated if a value is known
  class AUPSSuite100previewRetrieveAuPsBundleValidationTestsAuPsCompositionSubjectMustSupportElementsShallBePopulatedIfAValueIsKnown < BasicTest
    title 'Must Support elements SHALL be populated if a value is known'
    description 'Must Support elements SHALL be populated if a value is known'
    id :suite_100preview_retrieve_au_ps_bundle_validation_tests_au_ps_composition_subject_subject_ms_elements
    
    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../1.0.0-preview/metadata.yaml', __dir__))
    end
    
    run do
      
      ms_elements_populated_message("subject")
      
    end
    
  end
end

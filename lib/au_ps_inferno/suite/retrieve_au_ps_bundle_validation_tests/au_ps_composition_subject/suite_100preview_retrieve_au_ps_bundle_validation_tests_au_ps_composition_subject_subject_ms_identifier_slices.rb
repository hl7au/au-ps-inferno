# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'


module AUPSTestKit
  # Automatically generated primitive test for Must Support identifier slices SHALL be populated if a value is known
  class AUPSSuite100previewRetrieveAuPsBundleValidationTestsAuPsCompositionSubjectMustSupportIdentifierSlicesShallBePopulatedIfAValueIsKnown < BasicTest
    title 'Must Support identifier slices SHALL be populated if a value is known'
    description 'Must Support identifier slices SHALL be populated if a value is known (i.e. ihi, dva, medicare).'
    id :suite_100preview_retrieve_au_ps_bundle_validation_tests_au_ps_composition_subject_subject_ms_identifier_slices
    
    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../../metadata.yaml', __dir__))
    end
    
    run do
      
      test_subject_ms_identifier_slices
      
    end
    
  end
end

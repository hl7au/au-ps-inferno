# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'


module AUPSTestKit
  # Automatically generated primitive test for Must Support sub-element SHALL be populated if a value is known and the parent is populated
  class AUPSSuite100ballotRetrieveAuPsBundleValidationTestsAuPsCompositionSubjectMustSupportSubelementShallBePopulatedIfAValueIsKnownAndTheParentIsPopulated < BasicTest
    title 'Must Support sub-element SHALL be populated if a value is known and the parent is populated'
    description 'Must Support sub-element SHALL be populated if a value is known and the parent is populated'
    id :suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_composition_subject_subject_ms_subelements_populated
    
    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../1.0.0-ballot/metadata.yaml', __dir__))
    end
    
    run do
      
      ms_sub_elements_populated_message("subject")
      
    end
    
  end
end

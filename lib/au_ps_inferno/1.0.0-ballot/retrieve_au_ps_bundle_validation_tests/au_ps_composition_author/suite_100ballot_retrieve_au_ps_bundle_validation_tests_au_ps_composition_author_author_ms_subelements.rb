# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'


module AUPSTestKit
  # Automatically generated primitive test for Must Support sub-elements SHALL be populated if a value is known
  class AUPSSuite100ballotRetrieveAuPsBundleValidationTestsAuPsCompositionAuthorMustSupportSubelementsShallBePopulatedIfAValueIsKnown < BasicTest
    title 'Must Support sub-elements SHALL be populated if a value is known'
    description 'Must Support sub-elements SHALL be populated if a value is known'
    id :suite_100ballot_retrieve_au_ps_bundle_validation_tests_au_ps_composition_author_author_ms_subelements
    
    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../1.0.0-ballot/metadata.yaml', __dir__))
    end
    
    run do
      
      ms_sub_elements_populated_message("author")
      
    end
    
  end
end

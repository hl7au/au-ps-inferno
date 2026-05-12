# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'


module AUPSTestKit
  # Automatically generated primitive test for Subject reference in the AU PS Composition SHALL resolve to a valid resource type (Patient).
  class AUPSSuite100previewAuPsBundleInstanceAuPsCompositionSubjectSubjectReferenceInTheAuPsCompositionShallResolveToAValidResourceTypePatient < BasicTest
    title 'Subject reference in the AU PS Composition SHALL resolve to a valid resource type (Patient).'
    description 'Subject reference in the AU PS Composition SHALL resolve to a valid resource type (Patient).'
    id :suite_100preview_au_ps_bundle_instance_au_ps_composition_subject_subject_resource_type_is_valid
    
    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../1.0.0-preview/metadata.yaml', __dir__))
    end
    
    run do
      
      test_resource_type_is_valid?("subject")
      
    end
    
  end
end

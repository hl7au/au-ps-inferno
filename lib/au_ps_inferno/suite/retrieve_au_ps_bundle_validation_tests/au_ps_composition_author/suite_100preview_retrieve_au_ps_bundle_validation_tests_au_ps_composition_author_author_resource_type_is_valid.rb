# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'


module AUPSTestKit
  # Automatically generated primitive test for Author reference in the AU PS Composition SHALL resolve to a valid resource type (Practitioner, PractitionerRole, Device, Patient, RelatedPerson, Organization).
  class AUPSSuite100previewRetrieveAuPsBundleValidationTestsAuPsCompositionAuthorAuthorReferenceInTheAuPsCompositionShallResolveToAValidResourceTypePractitionerPractitionerroleDevicePatientRelatedpersonOrganization < BasicTest
    title 'Author reference in the AU PS Composition SHALL resolve to a valid resource type (Practitioner, PractitionerRole, Device, Patient, RelatedPerson, Organization).'
    description 'Author reference in the AU PS Composition SHALL resolve to a valid resource type (Practitioner, PractitionerRole, Device, Patient, RelatedPerson, Organization).'
    id :suite_100preview_retrieve_au_ps_bundle_validation_tests_au_ps_composition_author_author_resource_type_is_valid
    
    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../../metadata.yaml', __dir__))
    end
    
    run do
      
      test_resource_type_is_valid?("author")
      
    end
    
  end
end

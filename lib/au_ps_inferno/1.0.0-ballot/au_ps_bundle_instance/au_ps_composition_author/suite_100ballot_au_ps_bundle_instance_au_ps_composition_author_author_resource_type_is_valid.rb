# frozen_string_literal: true

require_relative '../../../utils/basic_test_class'
require_relative '../../../utils/metadata_manager'


module AUPSTestKit
  # Automatically generated primitive test for Author reference in the AU PS Composition SHALL resolve to a valid resource type (Practitioner, PractitionerRole, Device, Patient, RelatedPerson, Organization).
  class AUPSSuite100ballotAuPsBundleInstanceAuPsCompositionAuthorAuthorReferenceInTheAuPsCompositionShallResolveToAValidResourceTypePractitionerPractitionerroleDevicePatientRelatedpersonOrganization < BasicTest
    title 'Author reference in the AU PS Composition SHALL resolve to a valid resource type (Practitioner, PractitionerRole, Device, Patient, RelatedPerson, Organization).'
    description 'Author reference in the AU PS Composition SHALL resolve to a valid resource type (Practitioner, PractitionerRole, Device, Patient, RelatedPerson, Organization).'
    id :suite_100ballot_au_ps_bundle_instance_au_ps_composition_author_author_resource_type_is_valid
    
    def metadata_manager
      @metadata_manager ||= MetadataManager.new(File.expand_path('../../../1.0.0-ballot/metadata.yaml', __dir__))
    end
    
    run do
      
      test_resource_type_is_valid?("author")
      
    end
    
  end
end

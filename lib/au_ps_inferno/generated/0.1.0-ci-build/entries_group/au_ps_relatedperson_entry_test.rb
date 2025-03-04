# frozen_string_literal: true

module AUPSTestKit
  class AuPsRelatedpersonEntryTest < Inferno::TestGroup
    title 'AU PS RelatedPerson'
    description 'TODO description: AuPsRelatedpersonEntryTest'
    id :au_ps_au_ps_relatedperson_entry_test

    test do
      title 'Server returns correct RelatedPerson resource from the RelatedPerson read interaction'
      description %(
        This test will verify that RelatedPerson resources can be read from the server.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'RelatedPerson' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-relatedperson')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'RelatedPerson' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-relatedperson' found."

        existing_resources.each do |r|
          fhir_read('RelatedPerson', r.id)
          assert_response_status(200)
          assert_resource_type('RelatedPerson')

          assert resource.id == r.id,
                 "Requested resource with id #{r.id}, received resource with id #{resource.id}"
        end
      end
    end

    test do
      title 'Server returns RelatedPerson resource that matches the RelatedPerson profile'
      description %(
        This test will validate that the RelatedPerson resource returned from the server matches the Medication (IPS) profile.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'RelatedPerson' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-relatedperson')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'RelatedPerson' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-relatedperson' found."

        existing_resources.each do |r|
          assert_valid_resource(resource: r, profile_url: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-relatedperson')
        end
      end
    end
  end
end

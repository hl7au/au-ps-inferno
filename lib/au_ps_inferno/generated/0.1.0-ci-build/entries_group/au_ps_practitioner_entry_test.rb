# frozen_string_literal: true

module AUPSTestKit
  class AuPsPractitionerEntryTest < Inferno::TestGroup
    title 'AU PS Practitioner'
    description 'TODO description: AuPsPractitionerEntryTest'
    id :au_ps_au_ps_practitioner_entry_test

    test do
      title 'Server returns correct Practitioner resource from the Practitioner read interaction'
      description %(
        This test will verify that Practitioner resources can be read from the server.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'Practitioner' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-practitioner')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'Practitioner' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-practitioner' found."

        existing_resources.each do |r|
          fhir_read('Practitioner', r.id)
          assert_response_status(200)
          assert_resource_type('Practitioner')

          assert resource.id == r.id,
                 "Requested resource with id #{r.id}, received resource with id #{resource.id}"
        end
      end
    end

    test do
      title 'Server returns Practitioner resource that matches the Practitioner profile'
      description %(
        This test will validate that the Practitioner resource returned from the server matches the Medication (IPS) profile.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'Practitioner' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-practitioner')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'Practitioner' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-practitioner' found."

        existing_resources.each do |r|
          assert_valid_resource(resource: r, profile_url: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-practitioner')
        end
      end
    end
  end
end

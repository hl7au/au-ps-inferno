# frozen_string_literal: true

module AUPSTestKit
  class AuPsPractitionerroleEntryTest < Inferno::TestGroup
    title 'AU PS PractitionerRole'
    description 'TODO description: AuPsPractitionerroleEntryTest'
    id :au_ps_au_ps_practitionerrole_entry_test

    test do
      title 'Server returns correct PractitionerRole resource from the PractitionerRole read interaction'
      description %(
        This test will verify that PractitionerRole resources can be read from the server.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'PractitionerRole' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-practitionerrole')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'PractitionerRole' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-practitionerrole' found."

        existing_resources.each do |r|
          fhir_read('PractitionerRole', r.id)
          assert_response_status(200)
          assert_resource_type('PractitionerRole')

          assert resource.id == r.id,
                 "Requested resource with id #{r.id}, received resource with id #{resource.id}"
        end
      end
    end

    test do
      title 'Server returns PractitionerRole resource that matches the PractitionerRole profile'
      description %(
        This test will validate that the PractitionerRole resource returned from the server matches the Medication (IPS) profile.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'PractitionerRole' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-practitionerrole')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'PractitionerRole' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-practitionerrole' found."

        existing_resources.each do |r|
          assert_valid_resource(resource: r, profile_url: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-practitionerrole')
        end
      end
    end
  end
end

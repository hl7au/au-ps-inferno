# frozen_string_literal: true

module AUPSTestKit
  class AuPsImmunizationEntryTest < Inferno::TestGroup
    title 'AU PS Immunization'
    description 'TODO description: AuPsImmunizationEntryTest'
    id :au_ps_au_ps_immunization_entry_test

    test do
      title 'Server returns correct Immunization resource from the Immunization read interaction'
      description %(
        This test will verify that Immunization resources can be read from the server.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'Immunization' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-immunization')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'Immunization' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-immunization' found."

        existing_resources.each do |r|
          fhir_read('Immunization', r.id)
          assert_response_status(200)
          assert_resource_type('Immunization')

          assert resource.id == r.id,
                 "Requested resource with id #{r.id}, received resource with id #{resource.id}"
        end
      end
    end

    test do
      title 'Server returns Immunization resource that matches the Immunization profile'
      description %(
        This test will validate that the Immunization resource returned from the server matches the Medication (IPS) profile.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'Immunization' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-immunization')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'Immunization' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-immunization' found."

        existing_resources.each do |r|
          assert_valid_resource(resource: r, profile_url: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-immunization')
        end
      end
    end
  end
end

# frozen_string_literal: true

module AUPSTestKit
  class AuPsEncounterEntryTest < Inferno::TestGroup
    title 'AU PS Encounter'
    description 'TODO description: AuPsEncounterEntryTest'
    id :au_ps_au_ps_encounter_entry_test

    test do
      title 'Server returns correct Encounter resource from the Encounter read interaction'
      description %(
        This test will verify that Encounter resources can be read from the server.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'Encounter' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-encounter')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'Encounter' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-encounter' found."

        existing_resources.each do |r|
          fhir_read('Encounter', r.id)
          assert_response_status(200)
          assert_resource_type('Encounter')

          assert resource.id == r.id,
                 "Requested resource with id #{r.id}, received resource with id #{resource.id}"
        end
      end
    end

    test do
      title 'Server returns Encounter resource that matches the Encounter profile'
      description %(
        This test will validate that the Encounter resource returned from the server matches the Medication (IPS) profile.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'Encounter' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-encounter')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'Encounter' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-encounter' found."

        existing_resources.each do |r|
          assert_valid_resource(resource: r, profile_url: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-encounter')
        end
      end
    end
  end
end

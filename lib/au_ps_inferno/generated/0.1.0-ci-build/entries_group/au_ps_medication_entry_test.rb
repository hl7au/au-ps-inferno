# frozen_string_literal: true

module AUPSTestKit
  class AuPsMedicationEntryTest < Inferno::TestGroup
    title 'AU PS Medication'
    description 'TODO description: AuPsMedicationEntryTest'
    id :au_ps_au_ps_medication_entry_test

    test do
      title 'Server returns correct Medication resource from the Medication read interaction'
      description %(
        This test will verify that Medication resources can be read from the server.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'Medication' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medication')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'Medication' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medication' found."

        existing_resources.each do |r|
          fhir_read('Medication', r.id)
          assert_response_status(200)
          assert_resource_type('Medication')

          assert resource.id == r.id,
                 "Requested resource with id #{r.id}, received resource with id #{resource.id}"
        end
      end
    end

    test do
      title 'Server returns Medication resource that matches the Medication profile'
      description %(
        This test will validate that the Medication resource returned from the server matches the Medication (IPS) profile.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'Medication' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medication')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'Medication' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medication' found."

        existing_resources.each do |r|
          assert_valid_resource(resource: r, profile_url: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medication')
        end
      end
    end
  end
end

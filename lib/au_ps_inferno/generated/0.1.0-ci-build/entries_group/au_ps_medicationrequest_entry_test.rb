# frozen_string_literal: true

module AUPSTestKit
  class AuPsMedicationrequestEntryTest < Inferno::TestGroup
    title 'AU PS MedicationRequest'
    description 'TODO description: AuPsMedicationrequestEntryTest'
    id :au_ps_au_ps_medicationrequest_entry_test

    test do
      title 'Server returns correct MedicationRequest resource from the MedicationRequest read interaction'
      description %(
        This test will verify that MedicationRequest resources can be read from the server.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'MedicationRequest' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationrequest')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'MedicationRequest' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationrequest' found."

        existing_resources.each do |r|
          fhir_read('MedicationRequest', r.id)
          assert_response_status(200)
          assert_resource_type('MedicationRequest')

          assert resource.id == r.id,
                 "Requested resource with id #{r.id}, received resource with id #{resource.id}"
        end
      end
    end

    test do
      title 'Server returns MedicationRequest resource that matches the MedicationRequest profile'
      description %(
        This test will validate that the MedicationRequest resource returned from the server matches the Medication (IPS) profile.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'MedicationRequest' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationrequest')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'MedicationRequest' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationrequest' found."

        existing_resources.each do |r|
          assert_valid_resource(resource: r, profile_url: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationrequest')
        end
      end
    end
  end
end

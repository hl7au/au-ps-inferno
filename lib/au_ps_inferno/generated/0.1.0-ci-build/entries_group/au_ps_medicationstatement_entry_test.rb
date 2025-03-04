# frozen_string_literal: true

module AUPSTestKit
  class AuPsMedicationstatementEntryTest < Inferno::TestGroup
    title 'AU PS MedicationStatement'
    description 'TODO description: AuPsMedicationstatementEntryTest'
    id :au_ps_au_ps_medicationstatement_entry_test

    test do
      title 'Server returns correct MedicationStatement resource from the MedicationStatement read interaction'
      description %(
        This test will verify that MedicationStatement resources can be read from the server.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'MedicationStatement' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationstatement')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'MedicationStatement' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationstatement' found."

        existing_resources.each do |r|
          fhir_read('MedicationStatement', r.id)
          assert_response_status(200)
          assert_resource_type('MedicationStatement')

          assert resource.id == r.id,
                 "Requested resource with id #{r.id}, received resource with id #{resource.id}"
        end
      end
    end

    test do
      title 'Server returns MedicationStatement resource that matches the MedicationStatement profile'
      description %(
        This test will validate that the MedicationStatement resource returned from the server matches the Medication (IPS) profile.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'MedicationStatement' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationstatement')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'MedicationStatement' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationstatement' found."

        existing_resources.each do |r|
          assert_valid_resource(resource: r, profile_url: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-medicationstatement')
        end
      end
    end
  end
end

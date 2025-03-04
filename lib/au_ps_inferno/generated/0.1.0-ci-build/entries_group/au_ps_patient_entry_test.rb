# frozen_string_literal: true

module AUPSTestKit
  class AuPsPatientEntryTest < Inferno::TestGroup
    title 'AU PS Patient'
    description 'TODO description: AuPsPatientEntryTest'
    id :au_ps_au_ps_patient_entry_test

    test do
      title 'Server returns correct Patient resource from the Patient read interaction'
      description %(
        This test will verify that Patient resources can be read from the server.
      )

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'Patient' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-patient')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'Patient' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-patient' found."

        existing_resources.each do |r|
          fhir_read('Patient', r.id)
          assert_response_status(200)
          assert_resource_type('Patient')

          assert resource.id == r.id,
                 "Requested resource with id #{r.id}, received resource with id #{resource.id}"
        end
      end
    end

    test do
      title 'Server returns Patient resource that matches the Patient profile'
      description %(
        This test will validate that the Patient resource returned from the server matches the Medication (IPS) profile.
      )

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'Patient' && r.meta&.profile&.include?('http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-patient')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'Patient' with profile 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-patient' found."

        existing_resources.each do |r|
          assert_valid_resource(resource: r, profile_url: 'http://hl7.org.au/fhir/ps/StructureDefinition/au-ps-patient')
        end
      end
    end
  end
end

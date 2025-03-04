# frozen_string_literal: true

module AUPSTestKit
  class SpecimenIpsEntryTest < Inferno::TestGroup
    title 'Specimen (IPS)'
    description 'TODO description: SpecimenIpsEntryTest'
    id :au_ps_specimen_ips_entry_test

    test do
      title 'Server returns correct Specimen resource from the Specimen read interaction'
      description %(
        This test will verify that Specimen resources can be read from the server.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'Specimen' && r.meta&.profile&.include?('http://hl7.org/fhir/uv/ips/StructureDefinition/Specimen-uv-ips')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'Specimen' with profile 'http://hl7.org/fhir/uv/ips/StructureDefinition/Specimen-uv-ips' found."

        existing_resources.each do |r|
          fhir_read('Specimen', r.id)
          assert_response_status(200)
          assert_resource_type('Specimen')

          assert resource.id == r.id,
                 "Requested resource with id #{r.id}, received resource with id #{resource.id}"
        end
      end
    end

    test do
      title 'Server returns Specimen resource that matches the Specimen profile'
      description %(
        This test will validate that the Specimen resource returned from the server matches the Medication (IPS) profile.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'Specimen' && r.meta&.profile&.include?('http://hl7.org/fhir/uv/ips/StructureDefinition/Specimen-uv-ips')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'Specimen' with profile 'http://hl7.org/fhir/uv/ips/StructureDefinition/Specimen-uv-ips' found."

        existing_resources.each do |r|
          assert_valid_resource(resource: r, profile_url: 'http://hl7.org/fhir/uv/ips/StructureDefinition/Specimen-uv-ips')
        end
      end
    end
  end
end

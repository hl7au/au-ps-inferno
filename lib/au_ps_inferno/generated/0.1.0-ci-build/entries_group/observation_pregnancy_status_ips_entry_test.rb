# frozen_string_literal: true

module AUPSTestKit
  class ObservationPregnancyStatusIpsEntryTest < Inferno::TestGroup
    title 'Observation Pregnancy - Status (IPS)'
    description 'TODO description: ObservationPregnancyStatusIpsEntryTest'
    id :au_ps_observation_pregnancy_status_ips_entry_test

    test do
      title 'Server returns correct Observation resource from the Observation read interaction'
      description %(
        This test will verify that Observation resources can be read from the server.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'Observation' && r.meta&.profile&.include?('http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-pregnancy-status-uv-ips')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'Observation' with profile 'http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-pregnancy-status-uv-ips' found."

        existing_resources.each do |r|
          fhir_read('Observation', r.id)
          assert_response_status(200)
          assert_resource_type('Observation')

          assert resource.id == r.id,
                 "Requested resource with id #{r.id}, received resource with id #{resource.id}"
        end
      end
    end

    test do
      title 'Server returns Observation resource that matches the Observation profile'
      description %(
        This test will validate that the Observation resource returned from the server matches the Medication (IPS) profile.
      )

      optional

      uses_request :summary_operation

      run do
        initial_bundle = resource
        existing_resources = initial_bundle.entry.map(&:resource).select do |r|
          r.resourceType == 'Observation' && r.meta&.profile&.include?('http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-pregnancy-status-uv-ips')
        end

        skip_if existing_resources.empty?,
                "No existing resources of type 'Observation' with profile 'http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-pregnancy-status-uv-ips' found."

        existing_resources.each do |r|
          assert_valid_resource(resource: r, profile_url: 'http://hl7.org/fhir/uv/ips/StructureDefinition/Observation-pregnancy-status-uv-ips')
        end
      end
    end
  end
end
